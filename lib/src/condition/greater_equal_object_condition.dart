part of squilder.condition;

class GreaterEqualObjectCondition<T> with Condition {
  final TableField<T> field;
  final T object;

  GreaterEqualObjectCondition(this.field, this.object);

  String toSql() => "${field.toSql()} >= ${utils.objectToSql(object)}";
}
