library squilder.update_interfaces;

import 'package:squilder/src/condition.dart';
import 'package:squilder/src/serializable.dart';
import 'package:squilder/src/table_fields.dart';

abstract class UpdateSetFirstStep implements UpdateSetStep {}

abstract class UpdateSetStep {
  UpdateSetMoreStep setObj<T>(TableField field, T object);

  UpdateSetMoreStep setField(TableField field, TableField anotherField);
}

abstract class UpdateSetMoreStep implements UpdateSetStep, UpdateWhereStep {}

abstract class UpdateWhereStep implements UpdateFinalStep {
  UpdateWhereStep where(Condition condition);
}

abstract class UpdateFinalStep implements Serializable {}
