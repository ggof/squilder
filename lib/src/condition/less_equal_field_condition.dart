part of squilder.condition;

class LessEqualFieldCondition<T> with Condition {
  final TableField<T> fieldOne;
  final TableField<T> fieldTwo;

  LessEqualFieldCondition(this.fieldOne, this.fieldTwo);

  String toSql() => "${fieldOne.toSql()} <= ${fieldTwo.toSql()}";
}
