library squilder.test.support.tables;

import 'package:squilder/squilder.dart';

class OrderTable extends Table {
  late final OrderTableFields f;

  String get name => "orders";

  TableField<int> get primaryKey => f.id;

  OrderTable() {
    f = OrderTableFields(this);
  }
}

final OrderTable orders = new OrderTable();

class OrderTableFields extends TableFields {
  late final TableField<int> id;
  late final TableField<String> name;

  Iterable<TableField> get all => [id, name];

  OrderTableFields(Table table) {
    id = TableField<int>(table, "id");
    name = TableField<String>(table, "name");
  }
}

class OrderRecipientsTable extends Table {
  late final OrderRecipientsFields f;

  String get name => "order_recipients";

  TableField<int> get primaryKey => f.id;

  OrderRecipientsTable() {
    f = OrderRecipientsFields(this);
  }
}

final orderRecipients = OrderRecipientsTable();

class OrderRecipientsFields extends TableFields {
  final TableField<int> id;
  final TableField<String> name;
  final TableField<int> orderId;

  Iterable<TableField> get all => [id, name, orderId];

  OrderRecipientsFields(Table table)
      : id = TableField(table, "id"),
        name = TableField(table, "name"),
        orderId = TableField(table, "order_id");
}
