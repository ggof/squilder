part of squilder.condition;

class LessFieldCondition<T> with Condition {
  final TableField<T> fieldOne;
  final TableField<T> fieldTwo;

  LessFieldCondition(this.fieldOne, this.fieldTwo);

  String toSql() => "${fieldOne.toSql()} < ${fieldTwo.toSql()}";
}
