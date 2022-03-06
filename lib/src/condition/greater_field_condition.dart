part of squilder.condition;

class GreaterFieldCondition<T> with Condition {
  final TableField<T> fieldOne;
  final TableField<T> fieldTwo;

  GreaterFieldCondition(this.fieldOne, this.fieldTwo);

  String toSql() => "${fieldOne.toSql()} > ${fieldTwo.toSql()}";
}
