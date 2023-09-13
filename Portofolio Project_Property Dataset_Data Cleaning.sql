-- DATA CLEANING PROJECT

SELECT*
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing

-- 1. Standardize Date Format 

SELECT SaleDateConverted, CONVERT (date, saledate)
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing

UPDATE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
SET SaleDate = CONVERT (date, saledate)

ALTER TABLE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
SET SaleDateConverted = CONVERT (date, saledate)

-------------------------------------------------------------------------------------------------------------------

-- 2. Populate The Property Address Data 
-- A. We want to populate the property address eventhough there's difference unique ID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.propertyaddress, b.PropertyAddress)
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing as a
JOIN [PORTOFOLIO PROJECT].dbo.NashvilleHousing as b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


UPDATE a
SET PropertyAddress = ISNULL (a.propertyaddress, b.PropertyAddress)
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing as a
JOIN [PORTOFOLIO PROJECT].dbo.NashvilleHousing as b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

----------------------------------------------------------------------------------------------------------------------

-- 3. Breaking out Address into Individual Columns (Address, City, State) 
-- A. Check what inside the property address
-- B. Determine what is going to be break 
-- C. Using SUBSTRING to determine the character boundaries between the address
-- D. Using ALTER, UPDATE and ADD function to add new individual collumns 

SELECT PropertyAddress
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing
Order by ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, (CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress))  as Address
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing


SELECT
SUBSTRING (PropertyAddress, (CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress))  as Address
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing

ALTER TABLE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar (255);

UPDATE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar (255); 

UPDATE [PORTOFOLIO PROJECT].dbo.NashvilleHousing 
SET PropertySplitCity = SUBSTRING (PropertyAddress, (CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress))

SELECT *
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing 

--------------------------------------------------------------------------------------------------------------------------

-- 4. Breaking out Owner Addres using Parse Name

SELECT OwnerAddress
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing 

SELECT 
PARSENAME (Replace(OwnerAddress,',','.'), 3),
PARSENAME (Replace(OwnerAddress,',','.'), 2),
PARSENAME (Replace(OwnerAddress,',','.'), 1)
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing 


ALTER TABLE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar (255);

UPDATE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress,',','.'), 3)

ALTER TABLE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar (255);

UPDATE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (Replace(OwnerAddress,',','.'), 2)

ALTER TABLE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar (255);

UPDATE [PORTOFOLIO PROJECT].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (Replace(OwnerAddress,',','.'), 1)

SELECT *
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- 5. Change Y and N to YES and no in "Sold as Vacant" Field


SELECT Distinct (SoldAsVacant), COUNT (soldAsVacant)
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant, 
Case
	When SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [PORTOFOLIO PROJECT].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = Case
	When SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
------------------------------------------------------------------------------------------

-- 6. Remove Duplicates
-- Using CTE
-- Using Windows function to find duplicates 
-- For Project we pretend where the "UniqueID" is not there

WIth RowNumCTE AS (
SELECT *,
Row_Number() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) Row_Num
FROM NashvilleHousing
)
SELECT*
FROM RowNumCTE 
WHERE Row_Num > 1

------------------------------------------------------------------------------------------------

-- 7. Delete Unused Columns
-- Dropping the data for project purpose 

SELECT* 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP Column SaleDate

------------------------------------------------------------------------------------------

--7. Tidy things up for visualization purpose 
-- A. Change property split address to PropertyStreetAdr
-- B. Change PropertysplitCity PropertyCityAdr
-- C. Change OwnerSplitAddress to OwnerStreetAdr
-- D. Change Ownersplitcity to OwnerCityAdr
-- E. Change Ownersplitstate to OwnerStateAdr


SELECT*
FROM NashvilleHousing