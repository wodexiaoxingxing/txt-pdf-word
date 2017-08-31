USE [etest_zongbu]
GO
/****** Object:  StoredProcedure [dbo].[Pr_Money_GerenYue]    Script Date: 02/23/2017 10:06:58 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[Pr_Money_GerenYue]
AS
SET NOCOUNT ON
DECLARE @dt SMALLDATETIME = DATEADD(m, -2, GETDATE())

-------更新最近3个月的余额
WHILE @dt <= GETDATE() 
      BEGIN
            
            MERGE T_Money_gerenYue T
              USING 
                (
                  SELECT   grno, SUM(inmoney - outmoney) AS Yue
                  FROM    (
                            SELECT  grno, inmoney, outmoney, mandate
                            FROM    dbo.geren_liushui2013
                            UNION ALL
                            SELECT  grNo, money_yue, 0, Money_date
                            FROM    dbo.geren_yue
                          ) AS T_liushui
                  WHERE   DATEDIFF(m, T_liushui.mandate, @dt) >= 0
                  GROUP BY grno
                  HAVING  SUM(inmoney - outmoney) <> 0
                ) AS s
              ON DATEDIFF(m, T.YueDate, @dt) = 0 AND T.grNo = s.grno
              WHEN MATCHED AND T.Yue <> s.Yue THEN UPDATE SET T.Yue = s.Yue
              WHEN NOT MATCHED THEN  INSERT ( grNo, YueDate, Yue ) VALUES( s.grno, @dt, s.Yue )
              WHEN NOT MATCHED BY SOURCE  AND DATEDIFF(m, t.yuedate,@dt)=0 THEN DELETE;
            SET @dt = DATEADD(m, 1, @dt)
      END 
-----更新下  个人名字 身份证号    
       UPDATE T_Money_gerenYue
       SET    grName = T_gr.Name, grIDCard = T_gr.IDcard
       FROM   T_Money_gerenYue T_yue ,
              dbo.T_Customer_Geren T_gr
       WHERE  T_yue.grNo = T_gr.grNo
              AND T_yue.grName IS NULL




