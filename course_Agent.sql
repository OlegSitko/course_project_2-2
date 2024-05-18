-- Вывод данных из таблицы Object

SELECT * FROM AdminDB.Object_View; --- все объекты и клиенты
SELECT * FROM AdminDB.All_Objects_View; --- объекты
SELECT * FROM AdminDB.Buyers_View; --- все покупатели
SELECT * FROM AdminDB.Deal_View; --- все сделки
SELECT * FROM AdminDB.Client_View; --- все клиенты

--- оформление сделки
BEGIN
    AdminDB.create_deal(--ClientID, ObjectID, BuyerID, DealDate, Amount
    p_ClientID => 16,
    p_ObjectID => 5,
    p_BuyerID => 17,
    p_DealDate => SYSDATE,
    p_Amount => 50000
);
END;

--- заполняем объекты

BEGIN
    AdminDB.create_object(
        p_ObjectType => 'Дом',
        p_Addres => 'ул. Ленина, д. 10, кв. 15',
        p_Area => 85,
        p_NumRooms => 3,
        p_Price => 180000
    );
end;

begin    
    AdminDB.create_client(
        p_Login => 'user4',
        p_Password => 'password4',
        p_Name => 'Мария',
        p_LastName => 'ТМасинкевич',
        p_Email => 'maria.masinkevich@example.com',
        p_Phone => '123422'
    );
END;
--- создание нового клиента
    


BEGIN
   AdminDB.create_buyers(
        p_Login => 'user5',
        p_Password => 'password5',
        p_Name => 'Александр',
        p_LastName => 'ТМасинкевич',
        p_Email => 'alex.masinkevich@example.com',
        p_Phone => '232322'
    ); 
END;

begin
AdminDB.GenerateAgencyXML;
end;





