Select * from [dbo].[NashvilleHousing] where YearBuilt is not null

-- Creating a column that will be filled only by years
ALTER TABLE NashvilleHousing
ADD YearSold INT;

UPDATE NashvilleHousing
SET YearSold = YEAR(SaleDateConverted);

-- Showing sales by city region
Select PropertySplitCity,SUM(SalePrice) as SumSalePrice
From [dbo].[NashvilleHousing]
Group by PropertySplitCity
ORDER BY SumSalePrice desc 

-- Showing the Address and Property Type of the properties that were sold
SELECT PropertySplitAddress, LandUse, SUM(SalePrice) as SumSalePrice
FROM [dbo].[NashvilleHousing]
GROUP BY PropertySplitAddress, LandUse
ORDER BY SumSalePrice desc 

-- Showing the Value and Sold Price of the Property, along with the date it was sold
SELECT TotalValue, SalePrice, SaleDateConverted
FROM [dbo].[NashvilleHousing]
where TotalValue is not null AND SaleDateConverted != '2019-12-13'
GROUP BY TotalValue, SalePrice, SaleDateConverted
ORDER BY SaleDateConverted desc 

-- Showing relationship between property type, size of property, and sale price
SELECT Acreage, LandUse, SUM(SalePrice) as SumSalePrice
FROM [dbo].[NashvilleHousing]
where Acreage is not null
GROUP BY Acreage, LandUse
ORDER BY SumSalePrice desc 

-- Showing the wealthiest owners after property sales
SELECT OwnerName, SUM(SalePrice) as SumSalePrice
FROM [dbo].[NashvilleHousing]
where OwnerName is not null
GROUP BY OwnerName
ORDER BY SumSalePrice desc 

Select LandUse,SUM(SalePrice) as SumSalePrice
From [dbo].[NashvilleHousing]
Group by LandUse
ORDER BY SumSalePrice desc 

-- Showing sales based on year
SELECT YearSold, SUM(SalePrice) AS SumSalePrice
FROM [dbo].[NashvilleHousing]
WHERE YearSold IS NOT NULL
GROUP BY YearSold
ORDER BY SumSalePrice DESC

-- Showing sales based on when the property was built
Select YearBuilt,SUM(SalePrice) as SumSalePrice
From [dbo].[NashvilleHousing]
where YearBuilt is not null
Group by YearBuilt
ORDER BY YearBuilt desc 

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate) from [dbo].[NashvilleHousing]

Update NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address Data

Select * from dbo.NashvilleHousing --where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Breaking out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
from dbo.NashvilleHousing 
--where PropertyAddress is null
--order by ParcelID

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) as City
FROM dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant) from dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(3);

Select SoldAsVacant
, CASE When SoldAsVacant = '1' THEN 'Yes'
	When SoldAsVacant = '0' THEN 'No'
	ELSE SoldAsVacant
	END
From dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = '1' THEN 'YES'
	when SoldAsVacant = '0' THEN 'N0'
	ELSE SoldAsVacant
	END

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
					)row_num

From dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Remove Unused Columns
Select *
From dbo.NashvilleHousing


--ALTER TABLE dbo.NashvilleHousing
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
