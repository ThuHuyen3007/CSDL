create database BTN_2
use BTN_2
--
select * from BangDiem
--
SELECT HO_TEN,NGAY_SINH,SOBAODANH,
TRY_CONVERT(float,iif(CHARINDEX('Toán:',DIEM_THI)>0, SUBSTRING(DIEM_THI,8,4),null)) as Toan,
TRY_CONVERT(float,iif(CHARINDEX(N'Vật lí:',DIEM_THI)>0,SUBSTRING(DIEM_THI,CHARINDEX(N'Vật lí:',DIEM_THI)+9,5),null)) as VatLi,
TRY_CONVERT(float,iif(CHARINDEX(N'Hóa học:',DIEM_THI)>0,SUBSTRING(DIEM_THI,CHARINDEX(N'Hóa học:',DIEM_THI)+10,5),null)) as HoaHoc
into Bang FROM BangDiem
alter table Bang add TongDiem float;
update Bang set TongDiem = Toan+VatLi+HoaHoc
select * from Bang 

--1.Số học sinh có điểm toán, hóa, lí trên TB và phầm trăm số người đó trong mỗi môn
select 'Toan' as Mon, count(case when Toan>=5 then Toan end) as SL,
count(case when Toan>=5 then Toan end)*100.0/count(*) as PT from Bang
union
select 'Vat li' as Mon, count(case when VatLi>=5 then VatLi end) as SL,
count(case when VatLi>=5 then VatLi end)*100.0/count(*) as PT from Bang
union
select 'Hoa hoc'as Mon, count(case when HoaHoc>=5 then HoaHoc end) as SL,
count(case when HoaHoc>=5 then HoaHoc end)*100.0/count(*) as PT from Bang

/*2.Mỗi môn có bao nhiêu phầm trăm điểm giỏi (8-10), khá (6.5 – dưới 8),
TB (5 – dưới 6.5), Yếu (trên 1 – dưới 5), rớt (1 trở xuống)?*/
with B2 as
(select 'Toan' as Mon, count(case when Toan>=8 then Toan end)*100.0/count(*) as Gioi,
count(case when Toan>=6.5 and Toan<8 then Toan end)*100.0/count(*) as Kha,
count(case when Toan>=5 and Toan<6.5 then Toan end)*100.0/count(*) as TB,
count(case when Toan>1 and Toan<5 then Toan end)*100.0/count(*) as Yeu,
count(case when Toan<=1 then Toan end)*100.0/count(*) as Liet,
(count(*)-count(case when Toan>=0 then Toan end))*100.0/count(*) as Khong_thi from Bang
union
select 'Vat li' as Mon, count(case when VatLi>=8 then VatLi end)*100.0/count(*) as Gioi,
count(case when VatLi>=6.5 and VatLi<8 then VatLi end)*100.0/count(*) as Kha,
count(case when VatLi>=5 and VatLi<6.5 then VatLi end)*100.0/count(*) as TB,
count(case when VatLi>1 and VatLi<5 then VatLi end)*100.0/count(*) as Yeu,
count(case when VatLi<=1 then VatLi end)*100.0/count(*) as Liet,
(count(*) - count(case when VatLi>=0 then VatLi end))*100.0/count(*) as Khong_thi from Bang
union
select 'Hoa hoc' as Mon, count(case when HoaHoc>=8 then HoaHoc end)*100.0/count(*) as Gioi,
count(case when HoaHoc>=6.5 and HoaHoc<8 then HoaHoc end)*100.0/count(*) as Kha,
count(case when HoaHoc>=5 and HoaHoc<6.5 then HoaHoc end)*100.0/count(*) as TB,
count(case when HoaHoc>1 and HoaHoc<5 then HoaHoc end)*100.0/count(*) as Yeu,
count(case when HoaHoc<=1 then HoaHoc end)*100.0/count(*) as Liet, 
(count(*) - count(case when HoaHoc>=0 then HoaHoc end))*100.0/count(*) as Khong_thi from Bang)
select *, Gioi+Kha+TB+Yeu+Liet+Khong_thi as Tong from B2

--3. Những học sinh có điểm xét đại học nằm trong top 10 đầu.
select top 10 * from Bang
order by Tongdiem DESC

--4. Đối với mỗi khoảng điểm xét đại học thì có bao nhiêu học sinh?(Từ 0-15,15-20,20-25,25-30)
with B4 as(
select '25 - 30' as Khoang, count(case when TongDiem>=25 then TongDiem end) as So_luong from Bang
union select '20 - 25' as Khoang, count(case when TongDiem>=20 and TongDiem<25 then TongDiem end) from Bang
union select '15 - 20' as Khoang, count(case when TongDiem>=15 and TongDiem<20 then TongDiem end) from Bang
union select '0 - 15' as Khoang, count(case when TongDiem<15 then TongDiem end) from Bang
union select 'Khong thi khoi A' as Khoang, count(*) as So_luong from Bang where Tongdiem is null
union select 'Tong',count (*) from Bang)
select *,So_luong*100.0/17822 as Phan_tram from B4

--5. Tìm môn có điểm trung bình mỗi môn (dùng union)
select 'Trung binh', sum(Toan)/Count(Toan) as Toan, sum(Vatli)/Count(Vatli) as Vatli,
sum(HoaHoc)/Count(Hoahoc) as Hoahoc from Bang

--6. Những thí sinh đạt điểm 10 môn toán, Vật lý, Hóa học?
select * from Bang where Toan = 10 or VatLi=10 or HoaHoc=10

--7. Những thí sinh đạt điểm dưới trung bình trong cả 3 môn?
select * from Bang where Toan <5 and VatLi<5 and HoaHoc<5

--8.Điểm có nhiều thí sinh đạt được nhất?
with B8a as (Select Toan,count(Toan) as sl from Bang group by Toan)
select Toan from B8a where sl= (select max(sl) from B8a)

with B8b as (Select VatLi,count(VatLi) as sl from Bang group by VatLi)
select Vatli from B8b where sl= (select max(sl) from B8b)

with B8c as (Select HoaHoc,count(HoaHoc) as sl from Bang group by HoaHoc)
select HoaHoc from B8c where sl= (select max(sl) from B8c)