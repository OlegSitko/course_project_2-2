-- ����� ������ �� ������� Object

SELECT * FROM AdminDB.Object_View; --- ��� ������� � �������
SELECT * FROM AdminDB.All_Objects_View; --- �������
SELECT * FROM AdminDB.Buyers_View; --- ��� ����������
SELECT * FROM AdminDB.Deal_View; --- ��� ������
SELECT * FROM AdminDB.Client_View; --- ��� �������

--- ���������� ������
BEGIN
    AdminDB.create_deal(--ClientID, ObjectID, BuyerID, DealDate, Amount
    p_ClientID => 16,
    p_ObjectID => 5,
    p_BuyerID => 17,
    p_DealDate => SYSDATE,
    p_Amount => 50000
);
END;

--- ��������� �������

BEGIN
    AdminDB.create_object(
        p_ObjectType => '���',
        p_Addres => '��. ������, �. 10, ��. 15',
        p_Area => 85,
        p_NumRooms => 3,
        p_Price => 180000
    );
end;

begin    
    AdminDB.create_client(
        p_Login => 'user4',
        p_Password => 'password4',
        p_Name => '�����',
        p_LastName => '�����������',
        p_Email => 'maria.masinkevich@example.com',
        p_Phone => '123422'
    );
END;
--- �������� ������ �������
    


BEGIN
   AdminDB.create_buyers(
        p_Login => 'user5',
        p_Password => 'password5',
        p_Name => '���������',
        p_LastName => '�����������',
        p_Email => 'alex.masinkevich@example.com',
        p_Phone => '232322'
    ); 
END;

begin
AdminDB.GenerateAgencyXML;
end;





