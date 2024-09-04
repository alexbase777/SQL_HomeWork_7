CREATE TABLE Category  -- Создаём таблицу "Категория товара" 
(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, -- Первичный ключ ("Идентификатор категории")
    name TEXT NOT NULL -- "Наименование каткгории"
);

INSERT INTO Category (name) -- Заполняем таблицу Category 
VALUES ('Компьютерная техника'), ('Офис и канцелярия'), ('Мелкая бытовая техника');

CREATE TABLE Product -- Таблица "Товар"
(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, -- Первичный ключ
    name TEXT NOT NULL, -- Наименование продукта
    price INTEGER NOT NULL, -- Цена продукта
    id_product INTEGER,
    FOREIGN KEY (id_product) REFERENCES Category (id) ON DELETE CASCADE -- Внешний ключ
);

INSERT INTO Product (name, price, id_product) -- Заполняем таблицу 'Товар'
VALUES ('Кухонный комбайн KitchenAid 5KSM156', 1050, 3),
       ('Видеокарта Asus GeForce GT 1030', 20555, 1),
       ('Кулон', 500, 2),
       ('Игровая приставка Sony PlayStation', 45550, 1),
       ('Часы SmartWatch', 3560, 3);

CREATE TABLE Purchase -- Таблица "Продажа"
(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, -- Первичный ключ
    quantity INTEGER NOT NULL, -- Кол-во проданного товара
    date DATE NOT NULL, -- Дата продажи
    id_purchase INTEGER, 
    FOREIGN KEY (id_purchase) REFERENCES Product (id) ON DELETE CASCADE -- Внешний ключ
);

INSERT INTO Purchase (quantity, date, id_purchase) -- Заполняем таблицу 'Продажа'
VALUES (2, '2024-02-14', 3),
       (1, '2023-12-31', 2),
       (5, '2023-12-31', 1),
       (1, '2024-05-12', 4),
       (1, '2023-02-01', 5),
       (1, '2023-10-24', 5);
   
CREATE TABLE Customer -- Создайм таблицу 'Покупатель'
(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, -- Первичный ключ
    name TEXT NOT NULL, -- Имя покупателя
    famale VARCHAR(1), -- Пол покупателя
    age INTEGER NOT NULL, -- Возраст покупателя
    id_customer INTEGER,
    FOREIGN KEY (id_customer) REFERENCES Purchase (id) ON DELETE CASCADE -- Внешний ключ
);

INSERT INTO Customer (name, famale, age, id_customer) -- Заполняем таблицу 'Покупатель'
VALUES ('Вася', 'М', 37, 1),
       ('Петя', 'М', 20, 1),
       ('Маша', 'Ж', 18, 3),
       ('Таня', 'Ж', 22, 3),
       ('Соня', 'Ж', 33, 3),
       ('Женя', 'Ж', 44, 3),
       ('Нюра', 'Ж', 55, 3),
       ('Гоша', 'М', 15, 2),
       ('Сергей Иванович', 'М', 87, 4),
       ('Сеня', 'М', 17, 5),
       ('Вова', 'М', 32, 6);

-- Запрос 1: Сколько покупателей купили часы в 2023 году
SELECT COUNT() AS 'Количество покупателей' FROM Customer -- Формирукм таблицу с колонкой "Количество покупателей",
WHERE id_customer IN (SELECT id FROM Purchase -- где внешний ключ выбирается из диапазона значений таблицы "Продажи",
                      WHERE id_purchase = (SELECT id FROM Product -- где внешний ключ выюирается из диапазона значений таблицы "Продукты",
                                        WHERE Product.name LIKE 'Часы%') -- где наименование продукта начинается со слова "Часы"
                      AND DATE(Purchase.date) LIKE '2023%'); -- и дата в 2023 году
                    
-- Запрос 2: Каков средний возраст, купивших кулон 14 февраля
SELECT AVG(age) AS 'Средний возраст покупателя' FROM Customer -- Формирукм таблицу с колонкой "Средний возраст покупателя",
WHERE id_customer IN (SELECT id FROM Purchase -- где внешний ключ выбирается из диапазона значений таблицы "Продажи",
                     WHERE id_purchase IN (SELECT id FROM Product -- где внешний ключ выюирается из диапазона значений таблицы "Продукты",
                                         WHERE Product.name LIKE 'Кулон%') -- где наименование продукта начинается со слова "Кулон%"
                     AND DATE(Purchase.date) LIKE '%02-14'); -- и дата 14 февраля

-- Запрос 3: Каков "средний чек" покупок 31 декабря
SELECT CAST(Сумма AS REAL) / Количество AS 'Средний чек покупок за 31 декабря' FROM -- Под псевдонимом "Средний чек покупок за 31 декабря" выводим результат деления столбца 'Сумма' на столбец 'Кол-во' следующей таблицы (приводим тип данных к REAL с помощью ф.CAST):
    ( -- таблица с двумя колонками и одной строкой
        SELECT 
            (SELECT SUM(price * (SELECT quantity FROM Purchase WHERE id_purchase = Product.id)) -- Столбец 'Сумма' = сумме произведений цены товара на кол-во продаж 31 декабря 2023
                FROM Product WHERE id IN (SELECT id_purchase FROM Purchase WHERE date = '2023-12-31')) AS 'Сумма', 
            (SELECT SUM(quantity) FROM Purchase WHERE date = '2023-12-31') AS 'Количество' -- Столбец 'Кол-во' = сумме количеств продаж товаров 31 декабря 2023
    );