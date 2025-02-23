library squilder.schema_generator;

import 'dart:async';
import 'dart:io';

import 'package:squilder/src/generator/generator_config.dart';
import 'package:squilder/utils.dart';
import 'package:uuid/uuid.dart';

class _Field {
  final String name;
  final String type;
  final bool isNull;
  final dynamic defaultValue;

  _Field(this.name, this.type, this.isNull, this.defaultValue);

  String toString() {
    return "<_Field name: $name, type: $type, isNull: $isNull, defaultValue: $defaultValue>";
  }

  String get dartType {
    if (type.startsWith(new RegExp(r"(tiny|small|medium|big)?int"))) {
      return "int";
    } else if (type.startsWith(new RegExp(r"(tiny|small|medium|big)?blob")) ||
        type == "bytea") {
      return "List<int>";
    } else if (type.startsWith("varchar") ||
        type.startsWith(new RegExp(r"(tiny|small|medium|big)?text")) ||
        type.startsWith("char")) {
      return "String";
    } else if (type.startsWith("date") || type.startsWith("timestamp")) {
      return "DateTime";
    } else if (type.startsWith("decimal")) {
      return "double"; // for now
    } else if (type.startsWith("float") ||
        type.startsWith("double") ||
        type.startsWith("real")) {
      return "double";
    } else if (type == 'uuid') {
      return "String"; // for now
    } else {
      throw "Unknown type $type";
    }
  }

  String get camelizedName => camelize(name);
}

String _generateCodeForFieldDeclarations(Iterable<_Field> fields,
    {int shift: 2}) {
  return fields.map((field) {
    return """final TableField<${field.dartType}> ${field.camelizedName};""";
  }).join("\n\n${" " * shift}");
}

String sqlValueToDart(Object? value) {
  if (value is num) {
    return "$value";
  } else if (value == "NULL" || value == null) {
    return "null";
  } else {
    return "\"$value\"";
  }
}

String _generateCodeForFieldInitializations(Iterable<_Field> fields,
        {int shift = 2}) =>
    fields.map((field) {
      return """${field.camelizedName} = TableField<${field.dartType}>(table, "${field.name}", ${sqlValueToDart(field.defaultValue)})""";
    }).join(",\n" + ' ' * shift);

String _generateFieldGetters(Iterable<_Field> fields, {int shift = 2}) => fields
    .map((f) =>
        "TableField<${f.dartType}> get ${f.camelizedName} => f.${f.camelizedName};")
    .join(' ' * shift + "\n");

String _generateCodeForTable(String tableName, Iterable<_Field> fields) {
  var tableClass = "${camelize(tableName, capitalizeFirst: true)}Table";
  var fieldsClass = "${tableClass}Fields";
  var tableNameVar = camelize(tableName);
  var primaryKeyField =
      fields.firstWhere((f) => f.name == "id", orElse: () => fields.first);
  var allFields = fields.map((f) => f.camelizedName).join(", ");
  return """class $tableClass extends Table {
  String toString() => "$tableName";

  late final $fieldsClass f;
  
  ${_generateFieldGetters(fields)}

  TableField<${primaryKeyField.dartType}> get primaryKey => f.${primaryKeyField.camelizedName};

  $tableClass() {
    f = new $fieldsClass(this);
  }
}

final $tableNameVar = $tableClass();

class $fieldsClass extends TableFields {
  ${_generateCodeForFieldDeclarations(fields, shift: 2)}

  Iterable<TableField> get all => [$allFields];

  $fieldsClass($tableClass table) :
    ${_generateCodeForFieldInitializations(fields, shift: 4)};
}""";
}

Future<void> generate({
  String host = "localhost",
  String username = "root",
  required String password,
  int port = 3306,
  required String database,
  String output = "dbschema.dart",
  String library = "dbschema",
}) async {
  final config = GeneratorConfig.fromArgs(
    host: host,
    port: port,
    database: database,
    output: output,
    library: library,
    username: username,
    password: password,
  );

  final db = config.conn;

  await db.open();

  final query = """SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND 
    schemaname != 'information_schema';""";

  var tableNames = (await db.query(query)).map((r) => r[0]);
  var code = new StringBuffer();
  code.write("""library ${config.library};

import 'package:squilder/squilder.dart';

""");
  for (var tableName in tableNames) {
    var results = await db.query("""SELECT 
   column_name, 
   data_type,
   is_nullable,
   column_default
FROM 
   information_schema.columns
WHERE 
   table_name = '$tableName';""");
    var fields = results.map((result) => _Field(
          result[0],
          result[1].toString(),
          result[2] == "YES",
          result[3],
        ));
    code.writeln(_generateCodeForTable(tableName, fields));
  }
  new File(config.output).writeAsStringSync(code.toString());
  db.close();
}
