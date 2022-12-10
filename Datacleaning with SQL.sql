-1Select * from Portfolioproject.dbo.Nashvillehousing

--STANDARDIZE THE TABLE DATE FORMAT and let's Call the new column converted date

Select SaleDateConverted,CONVERT(Date,SaleDate) from Portfolioproject.dbo.Nashvillehousing

update Nashvillehousing SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashvillehousing 
add SaleDateConverted Date;

Update Nashvillehousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--FILL IN THE PROPERTY ADDRESS WITH NULLVALUES

Select * from Portfolioproject.dbo.Nashvillehousing
--Where PropertyAddress is NULL
Order by ParcelID

--In a Case where there are duplicate addresses,we will have to populate it using Self join(If ParcelID1=ParcelID2,then propertyAddress1=PropertyAddress2)
--All addresses even if they are the same have unique ParcelID.Having that in mind,we can populate isnull.

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolioproject.dbo.Nashvillehousing a
Join Portfolioproject.dbo.Nashvillehousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is NULL

--What the above Query is Saying is that,replace the null values with the PropertyAddress then update it.

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolioproject.dbo.Nashvillehousing a
Join Portfolioproject.dbo.Nashvillehousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is NULL

--Now we have successfully replaced the null values with property address

--LET US BREAK DOWN THE ADDRESS INTO COLUMNS (Address,City ,State)
Select PropertyAddress from Portfolioproject.dbo.Nashvillehousing
--Where PropertyAddress is NULL
--Order by ParcelID

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as address
from Portfolioproject.dbo.Nashvillehousing



ALTER TABLE Portfolioproject.dbo.Nashvillehousing 
add PropertySplitAddress NVarchar(255);

Update Portfolioproject.dbo.Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE Portfolioproject.dbo.Nashvillehousing 
add PropertySplitCity NVarchar(255);

Update Portfolioproject.dbo.Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))


--Now,we want to split the OwnerAddress like the PropertyAddress.

Select
SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) as Owner
,SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress) +1, LEN(OwnerAddress)) as Owner
from Portfolioproject.dbo.Nashvillehousing



ALTER TABLE Portfolioproject.dbo.Nashvillehousing 
add OwnerSplitAddress NVarchar(255);

Update Portfolioproject.dbo.Nashvillehousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress) -1) 

ALTER TABLE Portfolioproject.dbo.Nashvillehousing 
add OwnerSplitCity NVarchar(255);

Update Portfolioproject.dbo.Nashvillehousing
SET OwnerSplitCity = SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress) +1,LEN(OwnerAddress))

ALTER TABLE Portfolioproject.dbo.Nashvillehousing 
add OwnerSplitState NVarchar(255);

Update Portfolioproject.dbo.Nashvillehousing
SET OwnerSplitState = SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress) +12,LEN(OwnerAddress))


SELECT * from Portfolioproject.dbo.Nashvillehousing 

--CHANGE Y and N to YES and NO in "Sold As Vacant" column

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
from Portfolioproject.dbo.Nashvillehousing 
Group by SoldAsVacant
Order by 2


SELECT SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
      when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
from Portfolioproject.dbo.Nashvillehousing 


update Portfolioproject.dbo.Nashvillehousing 
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
      when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


--REMOVE DUPLICATES AND GET RID OF UNUSED COLUMNS
WITH RownumCTE as(
SELECT *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				     UniqueID
					 ) row_num
from Portfolioproject.dbo.Nashvillehousing 
--Order by ParcelID
) 
DELETE from RownumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--Now Let's Check if the duplicates are deleted
WITH RownumCTE as(
SELECT *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				     UniqueID
					 ) row_num
from Portfolioproject.dbo.Nashvillehousing 
--Order by ParcelID
) 
SELECT * from RownumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--Now Let's Delete Irrelevant Columns
SELECT * from Portfolioproject.dbo.Nashvillehousing

ALTER TABLE Portfolioproject.dbo.Nashvillehousing
Drop COLUMN TaxDistrict,PropertyAddress

ALTER TABLE Portfolioproject.dbo.Nashvillehousing
Drop COLUMN SaleDate



