set search_path = 'cc_user';
-- Query 1: Miramos la tabla 'store' ny revisamos el contenido

select *
from store 
limit 10; 

-- QUERY 2: Conteo de ordenes y clientes unicos 

SELECT COUNT(DISTINCT (ORDER_ID))
FROM STORE;

SELECT COUNT(DISTINCT (CUSTOMER_ID))
FROM STORE;

--QUERY 3: Informacion del cliente con id 1
SELECT CUSTOMER_ID, CUSTOMER_EMAIL, CUSTOMER_PHONE
FROM STORE
WHERE CUSTOMER_ID = 1;

---QUERY 4: Informacion del cliente con id 4
SELECT ITEM_1_ID, ITEM_1_NAME, ITEM_1_PRICE
FROM STORE
WHERE ITEM_1_ID =4;

--QUERY 5: Creacion de tabla 'customers' con datos unicos 
CREATE TABLE CUSTOMERS AS
SELECT DISTINCT CUSTOMER_ID,CUSTOMER_EMAIL, CUSTOMER_PHONE
FROM STORE;

--QUERY 6: CREAMOS LA LLAVE PRIMARIA EN CUSTOMERS QUE ES CUSTOMER_ID
ALTER TABLE CUSTOMERS
ADD PRIMARY KEY (CUSTOMER_ID);

--QUERY 7: Creacion de tabla 'items' consolidando items unicos 
CREATE TABLE ITEMS AS
SELECT DISTINCT ITEM_1_ID AS ITEM_ID, ITEM_1_NAME AS ITEM_NAME, ITEM_1_PRICE AS ITEM_PRICE
FROM STORE
WHERE ITEM_1_ID IS NOT NULL

UNION

SELECT DISTINCT ITEM_2_ID AS ITEM_ID, ITEM_2_NAME AS ITEM_NAME, ITEM_2_PRICE AS ITEM_PRICE
FROM STORE 
WHERE ITEM_2_ID IS NOT NULL 

UNION 

SELECT DISTINCT ITEM_3_ID AS ITEM_ID, ITEM_3_NAME AS ITEM_NAME, ITEM_3_PRICE AS ITEM_PRICE 
FROM STORE
WHERE ITEM_3_ID IS  NOT NULL;

--QUERY 8: Asignacion de clave primaria a 'items'
ALTER TABLE ITEMS 
ADD PRIMARY KEY (ITEM_ID);

--QUERY 9: Creacion de 'orders_itmes' para la relacion muchos-a-muchos entre ordenes e items
CREATE TABLE ORDERS_ITEMS AS
SELECT ORDER_ID, ITEM_1_ID AS ITEM_ID 
FROM STORE
WHERE ITEM_1_ID IS NOT NULL

UNION ALL 

SELECT ORDER_ID, ITEM_2_ID AS ITEM_ID
FROM STORE
WHERE ITEM_2_ID IS NOT NULL

UNION ALL 

SELECT ORDER_ID, ITEM_3_ID AS ITEM_ID
FROM STORE 
WHERE ITEM_3_ID IS NOT NULL;

--QUERY 10: Creacion de tabla 'orders' con datos unicos
CREATE TABLE ORDERS AS 
SELECT DISTINCT 
ORDER_ID,
ORDER_DATE,
CUSTOMER_ID
FROM STORE; 

--QUERY 11: Asignacion de clave primaria a 'orders'
ALTER TABLE ORDERS
ADD PRIMARY KEY (ORDER_ID);

--QUERY 12: Creacion nde claves foraneas entre tablas relacionadas 
ALTER TABLE ORDERS
ADD FOREIGN KEY (CUSTOMER_ID)
REFERENCES CUSTOMERS(CUSTOMER_ID)

ALTER TABLE ORDERS_ITEMS
ADD FOREIGN KEY (ITEM_ID)
REFERENCES ITEMS(ITEM_ID);

--QUERY 13: Agregar clave foranea en 'order_items' para referenciar a 'order'
ALTER TABLE ORDERS_ITEMS
ADD FOREIGN KEY (ORDER_ID)
REFERENCES ORDERS(ORDER_ID);

--Query 14: consulta en 'store' para obtener emails de ordenes posteriores al 25 de julio de 2019
SELECT DISTINCT
	CUSTOMER_EMAIL
FROM
	STORE
WHERE
	ORDER_DATE > '2019-07-25';

--QUERY 15:consulta usando tablas normalizadas
SELECT DISTINCT C.CUSTOMER_EMAIL
FROM ORDERS O
JOIN CUSTOMERS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
WHERE O.ORDER_DATE > '2019-07-25';

-- QUERY 16: conteo de items por ordenes en tabla no normalizada
WITH ALL_ITEMS AS(
SELECT ORDER_ID, ITEM_1_ID AS ITEM_ID FROM STORE
UNION ALL 
SELECT ORDER_ID, ITEM_2_ID FROM STORE
UNION ALL 
SELECT ORDER_ID, ITEM_3_ID FROM STORE
)
SELECT ITEM_ID, COUNT(DISTINCT ORDER_ID) AS ORDER_COUNT
FROM ALL_ITEMS
GROUP BY ITEM_ID
ORDER BY ITEM_ID;

--QUERY 17: conteo de ordenes por item enn tabla normalizada
SELECT OI.ITEM_ID, COUNT(DISTINCT OI.ORDER_ID)AS ORDER_COUNT
FROM ORDERS_ITEMS OI
GROUP BY OI.ITEM_ID
ORDER BY OI.ITEM_ID;

--QUERY 18
-- Ejercicio 18.1: Clientes con más de una orden
SELECT c.customer_email, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_email
HAVING COUNT(o.order_id) > 1;

-- Ejercicio 18.2: Órdenes posteriores al 15 de julio 2019 que incluyen una 'lámpara'
SELECT COUNT(DISTINCT o.order_id) AS lamp_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN items i ON oi.item_id = i.item_id
WHERE o.order_date > '2019-07-15'
  AND LOWER(i.item_name) LIKE '%lamp%';

-- Ejercicio 18.3: Órdenes que incluyen una 'silla'
SELECT COUNT(DISTINCT o.order_id) AS chair_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN items i ON oi.item_id = i.item_id
WHERE LOWER(i.item_name) LIKE '%chair%';






