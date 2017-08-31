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
----------记录合并号-----------------------
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
-----------------------将需要分钱的家庭放进 临时表--#temp_code_geren--------------------
  SELECT * INTO   #temp_code_geren  FROM (
   SELECT hebing_code, SUM (yuedi_yue)  AS yuedi_yue  FROM 
   (
  SELECT  hebing_code,MAX(yuedi_yue) AS yuedi_yue FROM dbo.v_geren_hebingkehu_new AS a
   INNER  JOIN 
    dbo.dz_hebingkehu AS b  
    ON a.CardId=b.geren_IdCard  

    WHERE yuedi_yue<0 AND  kehuType='个人客户' and act=1  AND workState=1 GROUP BY  hebing_Code 
 UNION ALL    
   SELECT  hebing_code,SUM(yuedi_yue) AS yuedi_yue FROM dbo.v_geren_hebingkehu_new AS a
   inner  JOIN 
    dbo.dz_hebingkehu AS b  
    ON a.CardId=b.geren_IdCard
    WHERE yuedi_yue>0 AND  kehuType='个人客户' and act=1 AND workState=1 GROUP BY  hebing_Code 
    )
    AS new GROUP BY hebing_code
 ) AS new1 WHERE yuedi_yue>=0
--------------------得到有几个 需要分钱的 家庭----------------------------
            SET @geshu = 0
            SELECT  @geshu = COUNT(*)
            FROM    #temp_code_geren 
            WHILE @geshu > 0 
            BEGIN
------------------------得到第一个 家庭的合并号--------------------------------------------
            SELECT TOP 1
                    @hebing_code = hebing_code
            FROM    #temp_code_geren
            WHERE   1 = 1
            ORDER BY hebing_code ASC
-----------------将 该家庭的钱  放进临时表#move_geren ---------------------------------------
            SELECT  *
            INTO    #move_geren
            FROM    dbo.v_geren_hebingkehu_new
            WHERE   CardId IN ( SELECT  geren_IdCard
            FROM    dbo.dz_hebingkehu
            WHERE   hebing_Code = @hebing_code  AND  kehuType='个人客户' )
            --SELECT * FROM #move_geren
 ---------------------------得到正数的和--------------------------------
            SELECT  @zheng_sum = SUM(yuedi_yue)
            FROM    #move_geren WHERE yuedi_yue>0   
---------------------------得到最大的正数--------------------------------
            SELECT TOP 1
            @zhengshu = yuedi_yue, --@y_id = id, 
            @y_no = grno,-- @y_db = db,
             @y_cardid = CardId, 
             @y_name = Name
            FROM    #move_geren WHERE yuedi_yue>0
            ORDER BY yuedi_yue DESC  
  --------------------------------得到负数 的个数-----------------------------
           SELECT   @count_fu=COUNT(*) FROM   #move_geren WHERE yuedi_yue<0      
----------------------如果有负数----------得到最大的负数-----------------------------
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
-------------------------------如果有负钱 而且 正钱够 用 开始循环---------------------------------------------------------
              WHILE @fushu < 0 AND @zheng_sum + @fushu >= 0  AND @count_fu>0
              BEGIN                        
------------------------满足条件时                  如果取得数 够弥补------------------------------------------
            IF @zhengshu + @fushu >= 0 AND @count_fu>0
             BEGIN
----------------------------------------------------------------------更新临时表-------------------
             UPDATE #move_geren SET    yuedi_yue = yuedi_yue + @fushu
             WHERE  grno = @y_no -- AND db=@y_db
             UPDATE #move_geren  SET    yuedi_yue = 0
             WHERE  grno = @m_no --AND db=@m_db
             ----------------插入 --money_geren_move--------
             INSERT INTO money_geren_move ( --[y_db], [m_db], [y_id],
             [y_grno],--[m_id],
             [m_grno],
              [y_cardid], [m_cardid], [y_name], [m_name], [money_move], txt )
             VALUES ( --@y_db,@m_db,@y_id,
             @y_no,-- @m_id,
              @m_no,@y_cardid, @m_cardid, @y_name, @m_name, ABS(@fushu), '' )
-----------------------------------------------------------------------更新 变量的值---------------
            SET @zhengshu = @zhengshu + @fushu
            SELECT @zheng_sum = SUM(yuedi_yue) FROM   #move_geren WHERE yuedi_yue>0 --正数的和
              --------------------------------得到负数 的个数-----------------------------
           SELECT   @count_fu=COUNT(*) FROM   #move_geren WHERE yuedi_yue<0 
             -----------------得到最大的负数-----------------------------
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
------------------------满足条件时                    如果取得数不够弥补------------------------------------------
          IF ( @zhengshu + @fushu ) < 0 AND @count_fu>0
          BEGIN  
----------------------------------------------------------------------更新临时表-------------------
          UPDATE #move_geren  SET    yuedi_yue = 0
          WHERE  grno = @y_no  --AND db=@y_db
          UPDATE #move_geren    SET    yuedi_yue = @zhengshu + @fushu
          WHERE  grno = @m_no  --AND db=@m_db
         ----------------插入 --money_geren_move--------
         IF @zhengshu>0 
         BEGIN
          INSERT INTO money_geren_move ( --[y_db], [m_db], [y_id],
          [y_grno],--[m_id],
          [m_grno], [y_cardid], [m_cardid], [y_name], [m_name], [money_move], txt )
          VALUES ( --@y_db,@m_db,  @y_id,
          @y_no ,--@m_id,
          @m_no, @y_cardid, @m_cardid, @y_name, @m_name, @zhengshu, '' )
          END
-----------------------------------------------------------------------更新 变量的值---------------
          SET @fushu = @zhengshu + @fushu
          SELECT @zheng_sum = SUM(yuedi_yue)   FROM   #move_geren WHERE yuedi_yue>0  --正数的和
          ---------------------------得到最大的正数--------------------------------
          SELECT TOP 1
          @zhengshu = yuedi_yue,
           --@y_id = id,
           @y_no=grno, --@y_db = db,
            @y_cardid = CardId, @y_name = Name
          FROM   #move_geren WHERE yuedi_yue>0
          ORDER BY yuedi_yue DESC 
          END   
END

-------------------需要 分配钱的 临时表 去掉 分配好的家庭-------------
           DELETE  FROM #temp_code_geren
           WHERE   hebing_code = @hebing_code
 --------------计算个数----------------
         SET @geshu = 0
         SELECT  @geshu = COUNT(*)
         FROM    #temp_code_geren 
------------------------一个家庭分配完毕后删除 临时表
          DROP TABLE #move_geren 
END 
DROP TABLE  #temp_code_geren --删除临时表(记录需要分钱的合并号)
END      


