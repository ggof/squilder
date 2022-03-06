library squilder.select;

import 'package:squilder/src/condition.dart';
import 'package:squilder/src/select_interfaces.dart';
import 'package:squilder/src/serializable.dart';
import 'package:squilder/src/table.dart';
import 'package:squilder/src/table_fields.dart';

SelectStep select(Iterable<TableField> fields) {
  return new Select._().select(fields);
}

class Select implements SelectStep, OffsetStep, JoinStep, OnStep {
  final Iterable<TableField> selectFields;
  final Iterable<Table> fromTables;
  final List<_JoinPair> joinPairs;
  final bool distinctValue;
  final List<OrderPair> orderPairs;
  final Iterable<TableField> groupFields;
  final Iterable<SelectStep> unionSelects;
  final Condition? whereCondition;
  final Condition? havingCondition;
  final int? limitValue;
  final int? offsetValue;

  Select._({
    this.selectFields = const [],
    this.fromTables = const [],
    this.distinctValue = false,
    this.joinPairs = const [],
    this.orderPairs = const [],
    this.groupFields = const [],
    this.unionSelects = const [],
    this.whereCondition,
    this.havingCondition,
    this.limitValue,
    this.offsetValue,
  });

  Select _update({
    Iterable<TableField>? selectFields,
    Iterable<Table>? fromTables,
    List<_JoinPair>? joinPairs,
    bool? distinctValue,
    List<OrderPair>? orderPairs,
    Iterable<TableField>? groupFields,
    Iterable<SelectStep>? unionSelects,
    Condition? whereCondition,
    Condition? havingCondition,
    int? limitValue,
    int? offsetValue,
  }) =>
      Select._(
        selectFields: selectFields ?? this.selectFields,
        fromTables: fromTables ?? this.fromTables,
        distinctValue: distinctValue ?? this.distinctValue,
        whereCondition: whereCondition ?? this.whereCondition,
        joinPairs: joinPairs ?? this.joinPairs,
        orderPairs: orderPairs ?? this.orderPairs,
        groupFields: groupFields ?? this.groupFields,
        unionSelects: unionSelects ?? this.unionSelects,
        havingCondition: havingCondition ?? this.havingCondition,
        limitValue: limitValue ?? this.limitValue,
        offsetValue: offsetValue ?? this.offsetValue,
      );

  SelectStep distinct() => _update(distinctValue: true);

  SelectStep from(Iterable<Table> tables) => _update(
      fromTables: []
        ..addAll(this.fromTables)
        ..addAll(tables));

  SelectStep where(Condition condition) =>
      _update(whereCondition: (whereCondition?.and(condition) ?? condition));

  String toSql() {
    final selectFieldsString = selectFields.map((f) => f.toSql()).join(", ");
    final tablesString = fromTables.map((t) => t.toSql()).join(", ");
    final distinctString = distinctValue ? " DISTINCT" : "";
    var thisSql =
        "(SELECT${distinctString} ${selectFieldsString} FROM ${tablesString}" +
            (joinPairs.isNotEmpty
                ? " ${joinPairs.map((t) => t.toSql()).join(" ")}"
                : "") +
            (whereCondition != null
                ? " WHERE ${whereCondition!.toSql()}"
                : "") +
            (groupFields.isNotEmpty
                ? " GROUP BY ${groupFields.map((f) => f.toSql()).join(', ')}"
                : "") +
            (havingCondition != null
                ? " HAVING ${havingCondition!.toSql()}"
                : "") +
            (orderPairs.isNotEmpty
                ? " ORDER BY ${orderPairs.map((op) => op.toSql()).join(', ')}"
                : "") +
            (limitValue != null ? " LIMIT $limitValue" : "") +
            (offsetValue != null ? " OFFSET $offsetValue" : "") +
            ")";
    var sqls = [thisSql]..addAll(unionSelects.map((us) => us.toSql()));
    var result = sqls.join(" UNION ");
    return result;
  }

  SelectStep select(Iterable<TableField> fields) => _update(
      selectFields: []
        ..addAll(this.selectFields)
        ..addAll(fields));

  OnStep innerJoin(Table table) => _join(JoinType.innerJoin, table);

  OnStep leftJoin(Table table) => _join(JoinType.leftJoin, table);

  OnStep rightJoin(Table table) => _join(JoinType.rightJoin, table);

  OnStep _join(JoinType type, Table table) {
    final joinPair = _JoinPair(type, table);
    final newJoinPairs = <_JoinPair>[]
      ..addAll(joinPairs)
      ..add(joinPair);
    return _update(joinPairs: newJoinPairs);
  }

  JoinStep on(Condition condition) {
    final joinPair = joinPairs.last.update(condition: condition);
    final newJoinPairs = <_JoinPair>[]..addAll(joinPairs);
    newJoinPairs[newJoinPairs.length - 1] = joinPair;
    return _update(joinPairs: newJoinPairs);
  }

  OrderByStep union(SelectStep select) => _update(
      unionSelects: []
        ..addAll(unionSelects)
        ..add(select));

  OffsetStep limit(int number) => _update(limitValue: number);

  OrderByStep orderBy(TableField field, OrderModifier modifier) => _update(
      orderPairs: []
        ..addAll(orderPairs)
        ..add(new OrderPair(field, modifier)));

  HavingStep having(Condition condition) => _update(havingCondition: condition);

  GroupByStep groupBy(Iterable<TableField> fields) => _update(
      groupFields: []
        ..addAll(groupFields)
        ..addAll(fields));

  UnionStep offset(int offset) => _update(offsetValue: offset);
}

class _JoinPair {
  final JoinType type;
  final Table table;
  final Condition? condition;

  _JoinPair(this.type, this.table, {this.condition});

  _JoinPair update({JoinType? type, Table? table, Condition? condition}) =>
      _JoinPair(
        type ?? this.type,
        table ?? this.table,
        condition: condition ?? this.condition,
      );

  // NOTE: calling this without setting the condition will throw
  String toSql() => "${type.toSql()} ${table.toSql()} ON ${condition!.toSql()}";
}

class OrderPair implements Serializable {
  final TableField field;
  final OrderModifier modifier;

  OrderPair(this.field, this.modifier);

  String toSql() {
    return "${field.toSql()} ${modifier.toSql()}";
  }
}
