/*
Cleaning Data in SQL Queries
*/

Select *
from ShemtovPortfolioProject..RafaNashvilleHousing

-- Standrdize saledate format

Select Converted_Date
from ShemtovPortfolioProject..RafaNashvilleHousing


alter table RafaNashvilleHousing
add Converted_Sales date;

update RafaNashvilleHousing
SET Converted_SalesDate = CONVERT(date,saledate)


-- Populate PropertyAddress Data

select *
from ShemtovPortfolioProject..RafaNashvilleHousing
where PropertyAddress is null
order by parcelID

-- SELF JOIN 
select A.parcelID, A.propertyAddress, B.parcelID, B.propertyAddress, ISNULL(A.propertyAddress,B.propertyAddress)
from ShemtovPortfolioProject..RafaNashvilleHousing A
JOIN ShemtovPortfolioProject..RafaNashvilleHousing B
	ON A.parcelID = B.parcelID
	and A.UniqueID <> B.UniqueID
where A.propertyAddress is null 

UPDATE A
SET A.propertyAddress = ISNULL(A.propertyAddress,B.propertyAddress)
from ShemtovPortfolioProject..RafaNashvilleHousing A
JOIN ShemtovPortfolioProject..RafaNashvilleHousing B
	ON A.parcelID = B.parcelID
	and A.UniqueID <> B.UniqueID
where A.propertyAddress is null 

				--//OR
 
 with cte1 as 
(select ParcelID
from ShemtovPortfolioProject..RafaNashvilleHousing A
where PropertyAddress is null),

cte2 as 
(select ParcelID, PropertyAddress
from ShemtovPortfolioProject..RafaNashvilleHousing 
WHERE PropertyAddress IS NOT NULL)


select PropertyAddress, c.ParcelID
from cte2 cc
join cte1 c 
on cc.ParcelID=c.ParcelID
where PropertyAddress is not null
--group by c.ParcelID, PropertyAddress



------------------------------------------------------------------------------------------------------------------------

-- breaking Address into Individual Colums (Address, City, State)

select PropertyAddress
from ShemtovPortfolioProject..RafaNashvilleHousing
--where PropertyAddress is null
--order by parcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from ShemtovPortfolioProject..RafaNashvilleHousing


alter table RafaNashvilleHousing
add PropertySplitAddress NVARCHAR(255);

update RafaNashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table RafaNashvilleHousing
add PropertySplitCity NVARCHAR(255);

update RafaNashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from ShemtovPortfolioProject..RafaNashvilleHousing

             --OR WE USE PARSENAMEEASY METHOD TO SPLITING


select OwnerAddress
from ShemtovPortfolioProject..RafaNashvilleHousing
	

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from ShemtovPortfolioProject..RafaNashvilleHousing


--&
alter table RafaNashvilleHousing
add OwnerSplitAddress NVARCHAR(255);

update RafaNashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


--&&
alter table RafaNashvilleHousing
add OwnerSplitCity NVARCHAR(255);

update RafaNashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


--&&&
alter table RafaNashvilleHousing
add OwnerSplitState NVARCHAR(255);

update RafaNashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select *
from ShemtovPortfolioProject..RafaNashvilleHousing


----------------------------------------------------------------------------------------------------------------

----Change Y and N to YES and NO in ''sold as Vacant'' field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from ShemtovPortfolioProject..RafaNashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


select SoldAsVacant
,	(CASE when SoldAsVacant = 'Y' THEN 'YES' 
		when SoldAsVacant = 'N' THEN 'NO' 
		ELSE SoldAsVacant 
		END)
from ShemtovPortfolioProject..RafaNashvilleHousing



UPDATE RafaNashvilleHousing
SET SoldAsVacant = (CASE when SoldAsVacant = 'Y' THEN 'YES' 
		when SoldAsVacant = 'N' THEN 'NO' 
		ELSE SoldAsVacant 
		END)


-----------------------------------------------------------------------------------------------------

-- Reomve Duplicates



with RowNumCTE AS(
select *,
	row_number() over (partition by parcelID, propertyAddress, saleprice, saledate, legalreference
	order by uniqueID) as row_num
from ShemtovPortfolioProject..RafaNashvilleHousing
--order by parcelID
)
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress



------------------------------------------------------------------------------------------------------------6

-- DELETE UNUSED COLUMNS

SELECT *
from ShemtovPortfolioProject..RafaNashvilleHousing

ALTER TABLE ShemtovPortfolioProject..RafaNashvilleHousing
DROP COLUMN OwnerAddress, taxdistrict, propertyaddress, saledate

ALTER TABLE ShemtovPortfolioProject..RafaNashvilleHousing
DROP COLUMN saledate