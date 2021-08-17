/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM Portfolio.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Portfolio.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM Portfolio.dbo.NashvilleHousing


--Populate Property Address Data
SELECT *
FROM Portfolio.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing AS a
JOIN Portfolio.dbo.NashvilleHousing AS b
  On a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing AS a
JOIN Portfolio.dbo.NashvilleHousing AS b
  On a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

SELECT *
FROM Portfolio.dbo.NashvilleHousing


SELECT OwnerAddress
FROM Portfolio.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE("OwnerAddress",',','.'),3) AS OwnerAddress
,PARSENAME(REPLACE("OwnerAddress",',','.'),2) AS OwnerCity
,PARSENAME(REPLACE("OwnerAddress",',','.'),1) AS OwnerState
From Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE("OwnerAddress",',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE("OwnerAddress",',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE("OwnerAddress",',','.'),1)




--Change Y and N to Yes and No in "SoldAsVacant

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE 
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END
FROM Portfolio.dbo.NashvilleHousing

UPDATE Portfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END



--Remove Duplication

WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			     UniqueID
				 ) row_num
FROM Portfolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			     UniqueID
				 ) row_num
FROM Portfolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



--DELETE Unused Columns

SELECT *
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, 

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate
