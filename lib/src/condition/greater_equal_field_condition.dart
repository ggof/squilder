part of squilder.condition;

class GreaterEqualFieldCondition<T> with Condition {
  final TableField<T> fieldOne;
  final TableField<T> fieldTwo;

  GreaterEqualFieldCondition(this.fieldOne, this.fieldTwo);

  String toSql() => "${fieldOne.toSql()} >= ${fieldTwo.toSql()}";
}
