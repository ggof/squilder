part of squilder.condition;

class GreaterObjectCondition<T> with Condition {
  final TableField<T> field;
  final T object;

  GreaterObjectCondition(this.field, this.object);

  String toSql() => "${field.toSql()} > ${utils.objectToSql(object)}";
}
