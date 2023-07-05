---cleaning data 
select *
from housingportfolio..Nashville

------standardize date format

select Saledateconverted, CONVERT(date, SaleDate)
from housingportfolio..Nashville

Update housingportfolio..Nashville
SET SaleDate=CONVERT(date, SaleDate)

alter table  Nashville
add Saledateconverted Date

Update housingportfolio..Nashville
SET Saledateconverted = CONVERT(date, SaleDate)

-----Populate property address data

Select *
from housingportfolio..Nashville
--where PropertyAddress is NULL
order by ParcelID

select x.ParcelID, x.PropertyAddress,
y.ParcelID, y.PropertyAddress,
ISNULL(x.PropertyAddress,y.PropertyAddress)
from housingportfolio..Nashville x
join housingportfolio..Nashville y
on x.ParcelID = y.ParcelID
	AND x.UniqueID != y.UniqueID
where x.PropertyAddress is NULL
--------

----isnull very powerful (x,y) check for x col for null if its null it replaces null with y col

UPDATE x
SET x.PropertyAddress = ISNULL(x.PropertyAddress,y.PropertyAddress)
from housingportfolio..Nashville x
join housingportfolio..Nashville y
on x.ParcelID = y.ParcelID
	AND x.UniqueID != y.UniqueID
where x.PropertyAddress is NULL

---------------------------------------
--Breaking out address into individual columns(Address, City,State)

Select PropertyAddress
from housingportfolio..Nashville
--where PropertyAddress is NULL
---order by ParcelID

--charindex helps to search or finds the characters mentioned in the column

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

from housingportfolio..Nashville

alter table housingportfolio..Nashville
add Address nvarchar(255)

Update housingportfolio..Nashville
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table housingportfolio..Nashville
add city nvarchar(20)

Update housingportfolio..Nashville
SET city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

------------------------------------
---Parsing is 
select OwnerAddress
from housingportfolio..Nashville

select
PARSENAME(REPLACE(OwnerAddress,',','.' ),3),
PARSENAME(REPLACE(OwnerAddress,',','.' ),2),
PARSENAME(REPLACE(OwnerAddress,',','.' ),1)
from housingportfolio..Nashville

alter table housingportfolio..Nashville
add OwnersplitAddress nvarchar(255)

Update housingportfolio..Nashville
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.' ),3)

alter table housingportfolio..Nashville
add Ownercity nvarchar(255)

Update housingportfolio..Nashville
SET Ownercity = PARSENAME(REPLACE(OwnerAddress,',','.' ),2)

alter table housingportfolio..Nashville
add Ownerstate nvarchar(255)

Update housingportfolio..Nashville
SET Ownerstate = PARSENAME(REPLACE(OwnerAddress,',','.' ),1)


select *
from housingportfolio..Nashville

----------------------------------------------------
--change from Yes or No to Yor N in SoldAsVacant

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from housingportfolio..Nashville
Group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
from housingportfolio..Nashville

UPDATE housingportfolio..Nashville
SET SoldAsVacant = CASE 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
---------------------------------------------------


----Remove Duplicates
with rownum_cte as(
Select *,
ROW_NUMBER() over(
	PARTITION BY ParcelID,
	PropertyAddress,
	Saleprice,
	SaleDate,
	LegalReference
	ORDER BY
	UniqueID
	) row_num
from housingportfolio..Nashville
)
--order by ParcelID

--DELETE (this statement will delete the row_num>1)
Select * 
from rownum_cte
where row_num>1
--order by PropertyAddress

----------------------------------------------------
-----drop unwanted columns

Select *
from housingportfolio..Nashville

ALTER TABLE housingportfolio..Nashville
DROP column TaxDistrict, PropertyAddress, SaleDate, OwnerAddress

