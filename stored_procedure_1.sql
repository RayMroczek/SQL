
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        <Ray Mroczek>
-- Create date: <04/07/23>
-- Description:   <example, retrieving open-ends from two-sided card>
-- =============================================

ALTER PROCEDURE [dbo].[FA_open_q15]

(

  @fieldingperiod int

)

AS


BEGIN

      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

drop table if exists  #languagevar
--Language helper table
CREATE TABLE #Languagevar(
 recordID int not null,
 lithoCode int not null,
 --revised 10.10, added english and spanish sums
 count_english int,
 count_spanish int,
 Language int)

INSERT INTO #Languagevar
SELECT Distinct recordID, lithoCode,
CASE WHEN Q1 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q2 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN len(Q3)>1 THEN 1 ELSE 0 END +
CASE WHEN Q4 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q5 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q6 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q7 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q8 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q9 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q10 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q11 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q12 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q13 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q14 IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN len(q15)>1 THEN 1 ELSE 0 END
as count_english,
CASE WHEN Q1_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q2_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN len(Q3_S)>1 THEN 1 ELSE 0 END +
CASE WHEN Q4_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q5_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q6_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q7_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q8_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q9_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q10_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q11_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q12_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q13_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN Q14_S IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN len(q15_S)>1 THEN 1 ELSE 0 END
as count_spanish,
1 as language
from tbl_name;

update #Languagevar
set Language=2
where count_spanish>count_english;


select distinct a.lithocode,
case when b.Language=1 then q15
when b.Language=2 then q15_s
end as q15
from tbl_name a
left join #Languagevar b
on a.LithoCode=b.lithocode
where a.fieldingPeriod=@fieldingperiod
and ((len(a.q15)>1 and b.Language=1) or (len(a.q15_s)>1 and b.Language=2))

END
GO
