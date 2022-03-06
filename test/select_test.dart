library squilder.test.select;

import 'package:squilder/squilder.dart';
import 'package:test/test.dart';
import 'support/tables.dart';

void main() {
  group('Select tests', () {
    final base = select([orders.f.id, orders.f.name]).from([orders]);
    final baseResponse = "SELECT `orders`.`id`, `orders`.`name` FROM `orders`";

    test('select from', () {
      expect(base.toSql(), "($baseResponse)");
    });

    test('where', () {
      final sql = base.where(orders.f.id.eqToObj(4));
      expect(sql.toSql(), "($baseResponse WHERE `orders`.`id` = 4)");
    });

    test('inner join', () {
      final sql = base.innerJoin(orderRecipients).on(orderRecipients.f.orderId.eqToField(orders.f.id));
      expect(sql.toSql(), "($baseResponse INNER JOIN `order_recipients` ON `order_recipients`.`order_id` = `orders`.`id`)");
    });

    test('left join', () {
      final sql = base.leftJoin(orderRecipients).on(orderRecipients.f.orderId.eqToField(orders.f.id));
      expect(sql.toSql(), "($baseResponse LEFT JOIN `order_recipients` ON `order_recipients`.`order_id` = `orders`.`id`)");
    });

    test('right join', () {
      final sql = base.rightJoin(orderRecipients).on(orderRecipients.f.orderId.eqToField(orders.f.id));
      expect(sql.toSql(), "($baseResponse RIGHT JOIN `order_recipients` ON `order_recipients`.`order_id` = `orders`.`id`)");
    });

    test('mixed joins', () {
      final sql = base
          .innerJoin(orderRecipients).on(orderRecipients.f.orderId.eqToField(orders.f.id))
          .leftJoin(orders).on(orders.f.id.eqToObj(8));
      expect(sql.toSql(), "($baseResponse INNER JOIN `order_recipients` ON `order_recipients`.`order_id` = `orders`.`id` LEFT JOIN `orders` ON `orders`.`id` = 8)");
    });

    test('order by', () {
      final sql = base.orderBy(orders.f.name, OrderModifier.ASC);
      expect(sql.toSql(), "($baseResponse ORDER BY `orders`.`name` ASC)");
    });

    test('group by', () {
      final sql = base.groupBy([orders.f.name, orders.f.id]);
      expect(sql.toSql(), "($baseResponse GROUP BY `orders`.`name`, `orders`.`id`)");
    });

    test('having', () {
      final sql = base.groupBy([orders.f.name, orders.f.id]).having(cond("foo = ?", ["bar"]));
      expect(sql.toSql(), "($baseResponse GROUP BY `orders`.`name`, `orders`.`id` HAVING foo = 'bar')");
    });

    test('limit and offset', () {
      final sql = base.limit(5).offset(8);
      expect(sql.toSql(), "($baseResponse LIMIT 5 OFFSET 8)");
    });

    test('union', () {
      final sql2 = select(orderRecipients.f.all).from([orderRecipients]).where(cond("foo = 1"));
      final sql = base.union(sql2);
      expect(sql.toSql(), "($baseResponse) UNION ${sql2.toSql()}");
    });
  });
}
