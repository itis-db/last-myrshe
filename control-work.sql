CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  category VARCHAR(50),
  price NUMERIC(10, 2)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_date DATE,
    customer_id INT
);

CREATE TABLE order_items (
     id SERIAL PRIMARY KEY,
     order_id INT REFERENCES orders(id),
     product_id INT REFERENCES products(id),
     quantity INT,
     amount NUMERIC(10, 2)
);

-- Очистка таблиц
TRUNCATE TABLE order_items, orders, products RESTART IDENTITY;
-- Товары
INSERT INTO products (name, category, price) VALUES
     ('Ноутбук Lenovo', 'Электроника', 45000.00),
     ('Смартфон Xiaomi', 'Электроника', 22000.50),
     ('Кофеварка Bosch', 'Бытовая техника', 15000.00),
     ('Футболка мужская', 'Одежда', 1500.00),
     ('Джинсы женские', 'Одежда', 3500.99),
     ('Шампунь Head&Shoulders', 'Косметика', 450.50),
     ('Книга "SQL для всех"', 'Книги', 1200.00),
     ('Монитор Samsung', 'Электроника', 18000.00),
     ('Чайник электрический', 'Бытовая техника', 2500.00),
     ('Кроссовки Nike', 'Одежда', 7500.00),
     ('Планшет Huawei', 'Электроника', 32000.00),
     ('Блендер Philips', 'Бытовая техника', 6500.00);
-- Заказы (за последние 2 года)
INSERT INTO orders (order_date, customer_id) VALUES
     ('2025-05-01', 101),
     ('2025-05-03', 102),
     ('2025-05-05', 103),
     ('2025-05-10', 104),
     ('2025-05-15', 101),
     ('2025-05-20', 105),
     ('2025-06-01', 102),
     ('2025-06-02', 103),
     ('2024-05-01', 104),
     ('2024-05-15', 105),
     ('2024-06-01', 101);
-- Позиции заказов
INSERT INTO order_items (order_id, product_id, quantity, amount) VALUES
     (1, 1, 1, 45000.00),
     (1, 8, 1, 18000.00),
     (2, 2, 1, 22000.50),
     (2, 4, 2, 3000.00),
     (3, 5, 1, 3500.99),
     (3, 10, 1, 7500.00),
     (3, 6, 3, 1351.50),
     (4, 3, 1, 15000.00),
     (4, 9, 1, 2500.00),
     (5, 11, 1, 32000.00),
     (5, 12, 1, 6500.00),
     (6, 7, 5, 6000.00),
     (7, 1, 1, 45000.00),
     (7, 2, 1, 22000.50),
     (8, 5, 2, 7001.98),
     (9, 3, 1, 15000.00),
     (9, 6, 2, 901.00),
     (10, 4, 3, 4500.00),
     (10, 10, 1, 7500.00),
     (11, 7, 2, 2400.00),
     (11, 11, 1, 32000.00);

-- 1 задание
SELECT
    p.category AS category,
    sum(oi.amount) AS total_sales,
    round(sum(oi.amount) / count(distinct oi.order_id), 2) as avg_per_order,
    round((sum(oi.amount) / sum(sum(oi.amount)) over ()) * 100, 2) as category_share
FROM order_items oi JOIN products p ON oi.product_id = p.id
GROUP BY p.category;

-- 2 задание
SELECT
    o.customer_id,
    o.id AS order_id,
    o.order_date,
    coalesce(sum(oi.amount), 0) as order_total,
    sum(sum(oi.amount)) over (partition by o.customer_id) as total_spent,
    round(avg(sum(oi.amount)) OVER (partition by o.customer_id), 2) as avg_order_amount,
    round(sum(oi.amount) - avg(sum(oi.amount)) OVER (partition by o.customer_id),2) as difference_from_avg
FROM orders o LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.customer_id, o.id, o.order_date
ORDER BY o.customer_id, o.order_date;

-- 3 задание
WITH monthly_sales as (
    SELECT to_char(o.order_date, 'YYYY-MM') as year_month, sum(oi.amount) as total_sales
    FROM orders o JOIN order_items oi on o.id = oi.order_id
    GROUP BY to_char(o.order_date, 'YYYY-MM')
)
SELECT
    year_month,
    total_sales,
    lag(total_sales, 1) over (ORDER BY year_month) AS prev_month_sales,
        round((total_sales - lag(total_sales, 1) over (ORDER BY year_month)) * 100.0 / nullif(lag(total_sales, 1) over (ORDER BY year_month), 0),2) as prev_month_diff,
    LAG(total_sales, 12) OVER (ORDER BY year_month) AS prev_year_sales,
        round((total_sales - lag(total_sales, 12) over (ORDER BY year_month)) * 100.0 / nullif(lag(total_sales, 12) over (order by year_month), 0), 2) as prev_year_diff
FROM monthly_sales
ORDER BY year_month;