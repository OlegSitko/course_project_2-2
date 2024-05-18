--- создание профиля безопасности и ролей для юзеров
alter session set "_ORACLE_SCRIPT"=true;
create role Agent_role;
create role Buyers_role;
create role Client_role;

grant 
create session,
create table,
create view
to Agent_role;
grant select on Object_View TO Agent_role;
grant select on Buyers_View TO Agent_role;
grant select on All_Objects_View to Agent_role;
grant select on Client_View to Agent_role;
grant select on Deal_View to Agent_role;

grant execute on create_object to Agent_role;
grant execute on create_client to Agent_role;
grant execute on create_buyers to Agent_role;
grant execute on test_insert_performance to Agent_role;
grant execute on create_deal to Agent_role;
grant execute on GenerateAgencyXML to Agent_role;


grant 
create session
to Buyers_role;
grant 
create session
to Client_role;

CREATE PROFILE pf_Agent LIMIT
PASSWORD_LIFE_TIME 640
SESSIONS_PER_USER 200 
FAILED_LOGIN_ATTEMPTS 7 
PASSWORD_LOCK_TIME 1 
PASSWORD_REUSE_TIME 10 
PASSWORD_GRACE_TIME DEFAULT 
CONNECT_TIME 180 
IDLE_TIME 30;

CREATE PROFILE pf_Buyers LIMIT
PASSWORD_LIFE_TIME 640
SESSIONS_PER_USER 200 
FAILED_LOGIN_ATTEMPTS 7 
PASSWORD_LOCK_TIME 1 
PASSWORD_REUSE_TIME 10 
PASSWORD_GRACE_TIME DEFAULT 
CONNECT_TIME 180 
IDLE_TIME 30;

CREATE PROFILE pf_Client LIMIT
PASSWORD_LIFE_TIME 640
SESSIONS_PER_USER 200 
FAILED_LOGIN_ATTEMPTS 7 
PASSWORD_LOCK_TIME 1 
PASSWORD_REUSE_TIME 10 
PASSWORD_GRACE_TIME DEFAULT 
CONNECT_TIME 180 
IDLE_TIME 30;

create user Agent
identified by Agent
default tablespace agency_ts
temporary tablespace agency_ts_tmp
profile pf_Agent
account unlock
password expire;

create user Buyers
identified by Buyers
default tablespace agency_ts
temporary tablespace agency_ts_tmp
profile pf_Buyers
account unlock
password expire;

create user Client
identified by Client
default tablespace agency_ts
temporary tablespace agency_ts_tmp
profile pf_Client
account unlock
password expire;

--- создание таблиц
create table Object (
    ObjectID int primary key,
    ObjectType varchar(255),
    Addres VARCHAR(255),
    Area decimal(10,2),
    NumRooms int,
    Price decimal(12,2)
);
create table Agency (
    AgencyID INT PRIMARY KEY,
    AgentID INT,
    Name VARCHAR(255),
    Address VARCHAR(255),
    Email VARCHAR(255),
    Phone VARCHAR(20),
    foreign key (AgentID) references Agents(AgentID)
);
create table Client (
    ClientID int primary key,
    ObjectID int,
    UserID int,
    foreign key (UserID) references DataUsers(UserID),
    foreign key (ObjectID) references Object(ObjectID)
);
create table Buyers (
    BuyerID int primary key,
    UserID int,
    foreign key (UserID) references DataUsers(UserID)
);
create table Agents (
    AgentID int primary key,
    UserID int,
    foreign key (UserID) references DataUsers(UserID)
);
create table Deal (
    DealID int primary key,
    AgentID int,
    AgencyID int,
    ClientID int,
    ObjectID int,
    BuyerID int,
    DealDate date,
    Amount decimal(12,2),
    foreign key (AgentID) references Agents(AgentID),
    foreign key (AgencyID) references Agency(AgencyID),
    foreign key (ClientID) references Client(ClientID),
    foreign key (ObjectID) references Object(ObjectID),
    foreign key (BuyerID) references Buyers(BuyerID)
);
create table DataUsers(
    UserID int primary key,
    Login varchar(10),
    Password varchar(10),
    Name VARCHAR(255),
    LastName VARCHAR(100),
    Email VARCHAR(255),
    Phone VARCHAR(20)
);
delete from DataUsers;
delete from Deal;
delete from Buyers;
delete from Client;
delete from Object;
delete from Agents;
select * from DataUsers;
select * from user_tables;

INSERT INTO Agency (AgencyID, AgentID, Name, Address, Email, Phone)
VALUES
    (1, 1, 'Best Homes Realty', '123 Main St, Anytown, USA', 'info@besthomes.com', '+1234567890');
insert into Agents (AgentID, UserID) 
values (1, 100);
INSERT INTO DataUsers (UserID, Login, Password, Name, LastName, Email, Phone)
VALUES (100, 'user1', 'password1', 'Иван', 'Иванов', 'ivan@example.com', '+1234567890');

--- представления
--Client_View
CREATE OR REPLACE VIEW Client_View AS
SELECT Client.ClientID, Client.UserID, DataUsers.Name, DataUsers.LastName, DataUsers.Email, DataUsers.Phone
FROM Client
INNER JOIN DataUsers ON Client.UserID = DataUsers.UserID;

--- сделки Deal
CREATE OR REPLACE VIEW Deal_View AS
SELECT D.DealID, O.ObjectID , O.ObjectType AS "Объект", D.DealDate AS "Дата Сделки", D.Amount AS "Сумма", DU.Name AS "Имя Покупателя", DU.LastName AS "Фамилия Покупателя", DU.Phone AS "Номер Телефона"
FROM Deal D
INNER JOIN Buyers B ON B.BuyerID = D.BuyerID
INNER JOIN DataUsers DU ON DU.UserID = B.UserID
INNER JOIN Object O ON O.ObjectID = D.ObjectID;


--все объекты и клиенты
CREATE OR REPLACE VIEW Object_View AS
select  ObjectType as Type, Addres, Area, NumRooms, Price,  Name, LastName, Email, Phone
from Object 
inner join Client on Object.ObjectID = Client.ObjectID 
inner join DataUsers on Client.UserID = DataUsers.UserID;


--- объекты
CREATE OR REPLACE VIEW All_Objects_View AS
select * from Object;

--- все покупатели
CREATE OR REPLACE VIEW Buyers_View AS
SELECT Buyers.BuyerID, Buyers.UserID, DataUsers.Name, DataUsers.LastName, DataUsers.Email, DataUsers.Phone
FROM Buyers
INNER JOIN DataUsers ON Buyers.UserID = DataUsers.UserID;


------------------------------------------------------- функции

CREATE OR REPLACE FUNCTION calculate_vat (
    p_amount DECIMAL
)
RETURN DECIMAL
IS
    v_vat_rate DECIMAL := 1.2; 
    v_vat DECIMAL;
BEGIN
    v_vat := p_amount * v_vat_rate;
    RETURN v_vat;
END calculate_vat;

------------------------------------------------------- тригеры
CREATE OR REPLACE TRIGGER trg_deal
BEFORE UPDATE ON Deal
FOR EACH ROW
BEGIN
    :NEW.AgentID := 1;
    :NEW.AgencyID:= 1;
END;

---------------------------------------------------- процедуры

CREATE OR REPLACE PROCEDURE create_client (
    p_Login VARCHAR2,
    p_Password VARCHAR2,
    p_Name VARCHAR2,
    p_LastName VARCHAR2,
    p_Email VARCHAR2,
    p_Phone VARCHAR2
)
IS
    v_UserID INT;
BEGIN
    DECLARE
        v_ClientID INT;
    BEGIN
        SELECT client_id_sequence.NEXTVAL INTO v_ClientID FROM DUAL;
        INSERT INTO DataUsers (UserID, Login, Password, Name, LastName, Email, Phone)
        VALUES (v_ClientID, p_Login, p_Password, p_Name, p_LastName, p_Email, p_Phone);
        INSERT INTO Client (ClientID, ObjectID, UserID)
        VALUES (v_ClientID, v_ClientID, v_ClientID);
        DBMS_OUTPUT.PUT_LINE('Данные успешно добавлены в таблицы DataUsers и Client.');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Нарушение уникального ограничения. Дублирующиеся значения.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка ' || SQLCODE || ': ' || SQLERRM);
    END;
END;
CREATE OR REPLACE PROCEDURE GenerateAgencyXML IS
xml_data CLOB;
BEGIN
    SELECT XMLELEMENT("Agency",
           XMLFOREST(AgencyID, AgentID, Name, Address, Email, Phone)
           ).getClobVal()
    INTO xml_data
    FROM Agency;
    DBMS_OUTPUT.PUT_LINE(xml_data);
END;


CREATE SEQUENCE client_id_sequence
START WITH 1
INCREMENT BY 1;
CREATE SEQUENCE object_id_sequence
START WITH 1
INCREMENT BY 1;
CREATE SEQUENCE seq_deal_id
START WITH 1
INCREMENT BY 1;
CREATE SEQUENCE buyer_sequence
START WITH 2
INCREMENT BY 1;
--- сощдание сделки
-- Пересоздание процедуры


CREATE OR REPLACE PROCEDURE create_deal (
    p_ClientID INT,
    p_ObjectID INT,
    p_BuyerID INT,
    p_DealDate DATE,
    p_Amount DECIMAL
) IS
BEGIN
    DECLARE
        v_DealID INT;
        v_CalculatedAmount DECIMAL;

    BEGIN
        SELECT seq_deal_id.NEXTVAL INTO v_DealID FROM DUAL;
   
    v_CalculatedAmount := calculate_vat(p_Amount);
    
    -- Вставка данных в таблицу Deal
    INSERT INTO Deal (DealID, ClientID, ObjectID, BuyerID, DealDate, Amount)
    VALUES (v_DealID, p_ClientID, p_ObjectID, p_BuyerID, p_DealDate, v_CalculatedAmount);
    
    -- Output a success message
    DBMS_OUTPUT.PUT_LINE('Данные успешно добавлены в таблицу Deal.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Нарушение уникального ограничения. Дублирующиеся значения.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка ' || SQLCODE || ': ' || SQLERRM);
    END;
END;
--- заполнение таблицы объектов
CREATE OR REPLACE PROCEDURE create_object (p_ObjectType VARCHAR2, p_Addres VARCHAR2, p_Area DECIMAL, p_NumRooms INT, p_Price DECIMAL)
IS
    v_ObjectID INT;
    v_ClientID INT;
BEGIN
    SELECT object_id_sequence.NEXTVAL INTO v_ObjectID FROM DUAL;
    SELECT object_id_sequence.NEXTVAL INTO v_ClientID FROM DUAL;
    
    -- Вставляем данные в таблицу Object
    INSERT INTO Object (ObjectID, ObjectType, Addres, Area, NumRooms, Price)
    VALUES (v_ObjectID, p_ObjectType, p_Addres, p_Area, p_NumRooms, p_Price);
    
    -- Вставляем данные в таблицу Client
    INSERT INTO Client (ClientID, ObjectID, UserID)
    VALUES (v_ClientID, v_ObjectID, v_ObjectID);
    
    -- Выводим сообщение об успешной вставке
    DBMS_OUTPUT.PUT_LINE('Данные успешно добавлены в таблицы Object и Client.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Нарушение уникального ограничения. Дублирующиеся значения.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка ' || SQLCODE || ': ' || SQLERRM);
END;
--- создание покупателя
CREATE OR REPLACE PROCEDURE create_buyers (
    p_Login IN VARCHAR2,
    p_Password IN VARCHAR2,
    p_Name IN VARCHAR2,
    p_LastName IN VARCHAR2,
    p_Email IN VARCHAR2,
    p_Phone IN VARCHAR2
)
IS
    v_BuyerID INT;
BEGIN
    -- Генерируем следующее значение для BuyerID из последовательности
    DECLARE
        v_BuyerID INT;
    BEGIN
        SELECT buyer_sequence.NEXTVAL INTO v_BuyerID FROM DUAL;
        
        -- Вставляем данные в таблицу DataUsers
        INSERT INTO DataUsers (UserID, Login, Password, Name, LastName, Email, Phone)
        VALUES (v_BuyerID, p_Login, p_Password, p_Name, p_LastName, p_Email, p_Phone);
        
        -- Вставляем данные в таблицу Buyers
        INSERT INTO Buyers (BuyerID, UserID)
        VALUES (v_BuyerID, v_BuyerID);
        
        -- Выводим сообщение об успешной вставке
        DBMS_OUTPUT.PUT_LINE('Данные успешно добавлены в таблицы DataUsers и Client.');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Нарушение уникального ограничения. Дублирующиеся значения.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка ' || SQLCODE || ': ' || SQLERRM);
    END;
END;




--- тестирование 10000 строк
CREATE SEQUENCE object_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
CREATE OR REPLACE PROCEDURE test_insert_performance AS
    v_object_id INT;
BEGIN
    FOR i IN 1..10000 LOOP
        -- Получаем следующее значение последовательности для ObjectID
        SELECT object_id_seq.NEXTVAL INTO v_object_id FROM DUAL;
        
        INSERT INTO Object (ObjectID, ObjectType, Addres, Area, NumRooms, Price)
        VALUES (v_object_id, 'Тип объекта ' || i, 'Адрес объекта ' || i, i * 10, i, i * 1000);
    END LOOP;
END test_insert_performance;
BEGIN
    test_insert_performance;
END;
select Area from Object where Price like '3%';



--- создание индекса
CREATE INDEX object_Price ON Object(Price);







----------------------------

select * from user_tables;


drop table Object;
drop table Agency;
drop table Buyers;
drop table Client;
drop table Deal;
drop table Agents;
drop table DataUsers;


drop procedure test_insert_performance
drop procedure create_client;
drop procedure create_object;
drop view Object_View;
drop INDEX object_Price;


ALTER SEQUENCE seq_deal_id RESTART START WITH 1; 
ALTER SEQUENCE buyer_sequence RESTART START WITH 1; 
ALTER SEQUENCE client_id_sequence RESTART START WITH 1; 
ALTER SEQUENCE object_id_sequence RESTART START WITH 1; 