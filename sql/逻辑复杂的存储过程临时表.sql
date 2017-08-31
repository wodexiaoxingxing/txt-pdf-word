USE [etest_zongbu]
GO
/****** Object:  StoredProcedure [dbo].[proc_2015_money_geren_move_new]    Script Date: 03/06/2017 14:19:48 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER        PROCEDURE [dbo].[proc_2015_money_geren_move_new]
AS 
      BEGIN 
----------��¼�ϲ���-----------------------
            DECLARE @hebing_code VARCHAR(50)
            DECLARE @geshu INT 
            DECLARE @zheng_sum [numeric](18, 2)
            DECLARE @y_no VARCHAR(50)
            DECLARE @m_no VARCHAR(50)
            DECLARE @y_db VARCHAR(50)
            DECLARE @m_db VARCHAR(50)
            DECLARE @y_id INT
            DECLARE @m_id INT
            DECLARE @y_cardid VARCHAR(50)
            DECLARE @m_cardid VARCHAR(50)
            DECLARE @y_name VARCHAR(50)
            DECLARE @m_name VARCHAR(50)
            DECLARE @zhengshu [numeric](18, 2)
            DECLARE @fushu [numeric](18, 2)
            DECLARE @count_fu INT
           -- select * from #temp_code_geren
-----------------------����Ҫ��Ǯ�ļ�ͥ�Ž� ��ʱ��--#temp_code_geren--------------------
  SELECT * INTO   #temp_code_geren  FROM (
   SELECT hebing_code, SUM (yuedi_yue)  AS yuedi_yue  FROM 
   (
  SELECT  hebing_code,MAX(yuedi_yue) AS yuedi_yue FROM dbo.v_geren_hebingkehu_new AS a
   INNER  JOIN 
    dbo.dz_hebingkehu AS b  
    ON a.CardId=b.geren_IdCard  

    WHERE yuedi_yue<0 AND  kehuType='���˿ͻ�' and act=1  AND workState=1 GROUP BY  hebing_Code 
 UNION ALL    
   SELECT  hebing_code,SUM(yuedi_yue) AS yuedi_yue FROM dbo.v_geren_hebingkehu_new AS a
   inner  JOIN 
    dbo.dz_hebingkehu AS b  
    ON a.CardId=b.geren_IdCard
    WHERE yuedi_yue>0 AND  kehuType='���˿ͻ�' and act=1 AND workState=1 GROUP BY  hebing_Code 
    )
    AS new GROUP BY hebing_code
 ) AS new1 WHERE yuedi_yue>=0
--------------------�õ��м��� ��Ҫ��Ǯ�� ��ͥ----------------------------
            SET @geshu = 0
            SELECT  @geshu = COUNT(*)
            FROM    #temp_code_geren 
            WHILE @geshu > 0 
            BEGIN
------------------------�õ���һ�� ��ͥ�ĺϲ���--------------------------------------------
            SELECT TOP 1
                    @hebing_code = hebing_code
            FROM    #temp_code_geren
            WHERE   1 = 1
            ORDER BY hebing_code ASC
-----------------�� �ü�ͥ��Ǯ  �Ž���ʱ��#move_geren ---------------------------------------
            SELECT  *
            INTO    #move_geren
            FROM    dbo.v_geren_hebingkehu_new
            WHERE   CardId IN ( SELECT  geren_IdCard
            FROM    dbo.dz_hebingkehu
            WHERE   hebing_Code = @hebing_code  AND  kehuType='���˿ͻ�' )
            --SELECT * FROM #move_geren
 ---------------------------�õ������ĺ�--------------------------------
            SELECT  @zheng_sum = SUM(yuedi_yue)
            FROM    #move_geren WHERE yuedi_yue>0   
---------------------------�õ���������--------------------------------
            SELECT TOP 1
            @zhengshu = yuedi_yue, --@y_id = id, 
            @y_no = grno,-- @y_db = db,
             @y_cardid = CardId, 
             @y_name = Name
            FROM    #move_geren WHERE yuedi_yue>0
            ORDER BY yuedi_yue DESC  
  --------------------------------�õ����� �ĸ���-----------------------------
           SELECT   @count_fu=COUNT(*) FROM   #move_geren WHERE yuedi_yue<0      
----------------------����и���----------�õ����ĸ���-----------------------------
            IF @count_fu>0
            BEGIN
             SELECT TOP 1
             @fushu = yuedi_yue,-- @m_id = id,
             @m_no=grno,
             -- @m_db = db, 
              @m_cardid = CardId,
               @m_name = Name
             FROM    #move_geren WHERE yuedi_yue<0
             ORDER BY yuedi_yue DESC 
            END  
-------------------------------����и�Ǯ ���� ��Ǯ�� �� ��ʼѭ��---------------------------------------------------------
              WHILE @fushu < 0 AND @zheng_sum + @fushu >= 0  AND @count_fu>0
              BEGIN                        
------------------------��������ʱ                  ���ȡ���� ���ֲ�------------------------------------------
            IF @zhengshu + @fushu >= 0 AND @count_fu>0
             BEGIN
----------------------------------------------------------------------������ʱ��-------------------
             UPDATE #move_geren SET    yuedi_yue = yuedi_yue + @fushu
             WHERE  grno = @y_no -- AND db=@y_db
             UPDATE #move_geren  SET    yuedi_yue = 0
             WHERE  grno = @m_no --AND db=@m_db
             ----------------���� --money_geren_move--------
             INSERT INTO money_geren_move ( --[y_db], [m_db], [y_id],
             [y_grno],--[m_id],
             [m_grno],
              [y_cardid], [m_cardid], [y_name], [m_name], [money_move], txt )
             VALUES ( --@y_db,@m_db,@y_id,
             @y_no,-- @m_id,
              @m_no,@y_cardid, @m_cardid, @y_name, @m_name, ABS(@fushu), '' )
-----------------------------------------------------------------------���� ������ֵ---------------
            SET @zhengshu = @zhengshu + @fushu
            SELECT @zheng_sum = SUM(yuedi_yue) FROM   #move_geren WHERE yuedi_yue>0 --�����ĺ�
              --------------------------------�õ����� �ĸ���-----------------------------
           SELECT   @count_fu=COUNT(*) FROM   #move_geren WHERE yuedi_yue<0 
             -----------------�õ����ĸ���-----------------------------
           IF @count_fu>0
           BEGIN
            SELECT TOP 1
            @fushu = yuedi_yue,-- @m_id = id,
            @m_no=grno,--@m_db = db,
             @m_cardid = CardId, @m_name = Name
            FROM   #move_geren WHERE yuedi_yue<0
            ORDER BY yuedi_yue DESC 
            END 
           END 
------------------------��������ʱ                    ���ȡ���������ֲ�------------------------------------------
          IF ( @zhengshu + @fushu ) < 0 AND @count_fu>0
          BEGIN  
----------------------------------------------------------------------������ʱ��-------------------
          UPDATE #move_geren  SET    yuedi_yue = 0
          WHERE  grno = @y_no  --AND db=@y_db
          UPDATE #move_geren    SET    yuedi_yue = @zhengshu + @fushu
          WHERE  grno = @m_no  --AND db=@m_db
         ----------------���� --money_geren_move--------
         IF @zhengshu>0 
         BEGIN
          INSERT INTO money_geren_move ( --[y_db], [m_db], [y_id],
          [y_grno],--[m_id],
          [m_grno], [y_cardid], [m_cardid], [y_name], [m_name], [money_move], txt )
          VALUES ( --@y_db,@m_db,  @y_id,
          @y_no ,--@m_id,
          @m_no, @y_cardid, @m_cardid, @y_name, @m_name, @zhengshu, '' )
          END
-----------------------------------------------------------------------���� ������ֵ---------------
          SET @fushu = @zhengshu + @fushu
          SELECT @zheng_sum = SUM(yuedi_yue)   FROM   #move_geren WHERE yuedi_yue>0  --�����ĺ�
          ---------------------------�õ���������--------------------------------
          SELECT TOP 1
          @zhengshu = yuedi_yue,
           --@y_id = id,
           @y_no=grno, --@y_db = db,
            @y_cardid = CardId, @y_name = Name
          FROM   #move_geren WHERE yuedi_yue>0
          ORDER BY yuedi_yue DESC 
          END   
END

-------------------��Ҫ ����Ǯ�� ��ʱ�� ȥ�� ����õļ�ͥ-------------
           DELETE  FROM #temp_code_geren
           WHERE   hebing_code = @hebing_code
 --------------�������----------------
         SET @geshu = 0
         SELECT  @geshu = COUNT(*)
         FROM    #temp_code_geren 
------------------------һ����ͥ������Ϻ�ɾ�� ��ʱ��
          DROP TABLE #move_geren 
END 
DROP TABLE  #temp_code_geren --ɾ����ʱ��(��¼��Ҫ��Ǯ�ĺϲ���)
END      


