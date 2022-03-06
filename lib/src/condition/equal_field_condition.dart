part of squilder.condition;

class EqualFieldCondition<T> with Condition {
  final TableField<T> fieldOne;
  final TableField<T> fieldTwo;

  EqualFieldCondition(this.fieldOne, this.fieldTwo);

  String toSql() {
    return "${fieldOne.toSql()} = ${fieldTwo.toSql()}";
  }
}

