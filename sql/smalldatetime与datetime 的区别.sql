    /*  
    smalldatetime ��datetime ������
  1:smalldatetime ��ȷȡ����,datetime ��ȷȡ��3.33����
  2:ʱ��β�һ�� smalldatetime(1900/1/1~2079/6/6)  datetime(1753/1/1~9999/12/31)
  3:smalldatetime ���ڵ���30�� ��������Ϊ1����
    */              
DECLARE @dt DATETIME  = DATEADD(m, -2, GETDATE())
WHILE @dt < =GETDATE() 
      BEGIN
          SELECT  @dt 
            SET @dt = DATEADD(m, 1, @dt)
      END 
      
 PRINT '-----------------------------'                       
DECLARE @dt1 SMALLDATETIME  = DATEADD(m, -2, GETDATE())
WHILE @dt1 < =GETDATE() 
      BEGIN
       SELECT  @dt1 
       SET @dt1 = DATEADD(m, 1, @dt1)
END 