library squilder.update;

import 'package:squilder/src/condition.dart';
import 'package:squilder/src/table.dart';
import 'package:squilder/src/table_fields.dart';
import 'package:squilder/src/update_interfaces.dart';

UpdateSetFirstStep update(Table table) => Update._(table);

class Update implements UpdateSetFirstStep, UpdateSetMoreStep {
  final Table table;
  final Iterable<Condition> sets;
  final Condition? whereCondition;

  Update._(this.table, {this.whereCondition, this.sets = const []});

  Update _update({
    Table? table,
    Condition? whereCondition,
    Iterable<Condition> sets = const [],
  }) =>
      Update._(
        table ?? this.table,
        whereCondition: whereCondition ?? this.whereCondition,
        sets: sets,
      );

  String toSql() {
    var sql = "UPDATE ${table.toSql()} SET ";
    sql += sets.map((c) => c.toSql()).join(", ");
    if (whereCondition != null) {
      sql += " WHERE (${whereCondition!.toSql()})";
    }
    return sql;
  }

  UpdateSetMoreStep setField(TableField field, TableField anotherField) {
    var condition = EqualFieldCondition(field, anotherField);
    return _update(
        sets: <Condition>[]
          ..addAll(this.sets)
          ..add(condition));
  }

  UpdateSetMoreStep setObj<T>(TableField field, T object) {
    var condition = EqualObjectCondition(field, object);
    return _update(
        sets: <Condition>[]
          ..addAll(this.sets)
          ..add(condition));
  }

  UpdateWhereStep where(Condition condition) =>
      _update(whereCondition: (whereCondition?.and(condition) ?? condition));
}
