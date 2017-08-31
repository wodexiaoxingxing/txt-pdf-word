USE [etest]
GO

/****** Object:  View [dbo].[geren_all_duizhang_bank_new]    Script Date: 03/06/2017 14:42:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[geren_all_duizhang_bank_new]
AS 
SELECT  grNo, name AS kehuname, idcard AS cardid, dz_bank_name1 AS bank_bankName , dz_bank_username1 AS bank_username, dz_bank_num1 AS bank_num
FROM    etest_zongbu..T_Customer_Geren
WHERE   LEN(dz_bank_num1) > 8
       -- AND ActFalg = 1
UNION ALL
SELECT  grNo, name AS kehuname, idcard, dz_bank_name2, dz_bank_username2, dz_bank_num2
FROM    etest_zongbu..T_Customer_Geren
WHERE   LEN(dz_bank_num2) > 8
       -- AND ActFalg = 1
UNION ALL
SELECT  grNo, name AS kehuname, idcard, dz_bank_name3, dz_bank_username3, dz_bank_num3
FROM    etest_zongbu..T_Customer_Geren
WHERE   LEN(dz_bank_num3) > 8
      --  AND ActFalg = 1
UNION ALL
SELECT  grNo, name AS kehuname, idcard, dz_bank_name4, dz_bank_username4, dz_bank_num4
FROM    etest_zongbu..T_Customer_Geren
WHERE   LEN(dz_bank_num4) > 8
       -- AND ActFalg = 1
UNION ALL
SELECT  grNo, name AS kehuname, idcard, dz_bank_name5, dz_bank_username5, dz_bank_num5
FROM    etest_zongbu..T_Customer_Geren
WHERE   LEN(dz_bank_num5) > 8
      --  AND ActFalg = 1



GO


