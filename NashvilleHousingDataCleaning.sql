

--Cleaning Data

Select * 
From HousingPortfolioProject.dbo.NashvilleHousing

-- Fixing SaleDate
Select SaleDateConverted, CONVERT(Date,SaleDate)
From HousingPortfolioProject..NashvilleHousing

Update HousingPortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE HousingPortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update HousingPortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populating Property Address
Select *
from HousingPortfolioProject.dbo.NashvilleHousing
--where PropertyAddress  is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from HousingPortfolioProject.dbo.NashvilleHousing a 
JOIN HousingPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from HousingPortfolioProject.dbo.NashvilleHousing a 
JOIN HousingPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]



-- Breaking Address into Individual Columns (Address, City, State)

Select PropertyAddress
From HousingPortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From HousingPortfolioProject.dbo.NashvilleHousing


ALTER TABLE HousingPortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update HousingPortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE HousingPortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update HousingPortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



Select * 
From HousingPortfolioProject..NashvilleHousing



-- Splitting Owner Address Into Address, City and State

Select OwnerAddress 
From HousingPortfolioProject..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From HousingPortfolioProject..NashvilleHousing


ALTER TABLE HousingPortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update HousingPortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE HousingPortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update HousingPortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE HousingPortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update HousingPortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From HousingPortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldasVacant)
From HousingPortfolioProject..NashvilleHousing
Group By SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From HousingPortfolioProject..NashvilleHousing


Update HousingPortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
					When SoldAsVacant = 'N' Then 'No'
					Else SoldAsVacant
					End

--------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From HousingPortfolioProject..NashvilleHousing
--Order By ParcelID
)
DELETE
From RowNumCTE
where row_num > 1

 
 ----------------------------------------------------------------------------------------
 
 --Delete Unused Columns
 Select * 
 From HousingPortfolioProject..NashvilleHousing

 ALTER TABLE HousingPortfolioProject..NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 
 ALTER TABLE HousingPortfolioProject..NashvilleHousing
 DROP COLUMN SaleDate


