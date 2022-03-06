library squilder.table;

import 'package:squilder/src/serializable.dart';
import 'package:squilder/src/table_fields.dart';
import 'package:squilder/utils.dart' as utils;

abstract class Table implements Serializable {
  TableFields get f;

  TableField get primaryKey;

  String toSql() {
    return "`${utils.escape(toString())}`";
  }

  String toString();

  bool operator ==(other) => other is Table && other.toString() == toString();

  int get hashCode => toString().hashCode;
}
