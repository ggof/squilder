library squilder.table_fields;

import 'package:squilder/src/condition.dart';
import 'package:squilder/src/serializable.dart';
import 'package:squilder/src/table.dart';
import 'package:squilder/utils.dart' as utils;

abstract class TableFields {
  Iterable<TableField> get all;
}

class TableField<T> implements Serializable {
  final String name;
  final Table table;
  final String? defaultValue;

  TableField(this.table, this.name, [this.defaultValue]);

  EqualFieldCondition<T> eqToField(TableField<T> field) =>
      EqualFieldCondition<T>(this, field);

  EqualObjectCondition<T> eqToObj(T obj) => EqualObjectCondition<T>(this, obj);

  LessFieldCondition<T> ltField(TableField<T> field) =>
      LessFieldCondition<T>(this, field);

  LessObjectCondition<T> ltObj(T obj) => LessObjectCondition<T>(this, obj);

  LessEqualFieldCondition<T> lteField(TableField<T> field) =>
      LessEqualFieldCondition<T>(this, field);

  LessEqualObjectCondition<T> lteObj(T obj) =>
      LessEqualObjectCondition<T>(this, obj);

  GreaterFieldCondition<T> gtField(TableField<T> field) =>
      GreaterFieldCondition<T>(this, field);

  GreaterObjectCondition<T> gtObj(T obj) =>
      GreaterObjectCondition<T>(this, obj);

  GreaterEqualFieldCondition<T> gteField(TableField<T> field) =>
      GreaterEqualFieldCondition<T>(this, field);

  GreaterEqualObjectCondition<T> gteObj(T obj) =>
      GreaterEqualObjectCondition<T>(this, obj);

  Condition like(String pattern) => LikeCondition(this, pattern);

  String toSql() => "${table.toSql()}.`${utils.escape(name)}`";

  bool operator ==(other) =>
      other is TableField && other.name == name && other.table == table;

  int get hashCode => name.hashCode ^ table.hashCode;
}
