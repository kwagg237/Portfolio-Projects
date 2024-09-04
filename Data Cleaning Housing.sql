--Cleaning Data

select *
from NashvilleHousing



--Standardize Date Format

select SaleDate, Convert(Date, SaleDate)
from NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



--Populate Property Address Data

select PropertyAddress
from NashvilleHousing
where PropertyAddress is null

select *
from NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b 
	on a.ParcelID = b. ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b 
	on a.ParcelID = b. ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null



--Breaking up Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as 'Address',
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress)) as 'City'
from NashvilleHousing


Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress))


Select *
from NashvilleHousing

Select OwnerAddress
from NashvilleHousing


select 
PARSENAME(replace(OwnerAddress, ',','.'), 3),
PARSENAME(replace(OwnerAddress, ',','.'), 2),
PARSENAME(replace(OwnerAddress, ',','.'), 1)
from NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'), 1)

select *
from NashvilleHousing



--Change Y and N in "Sold as Vacant" field to Yes and No

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
from NashvilleHousing


UPDATE NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End



--Remove Duplicates

WITH RowNumCTE as (
Select *, 
	ROW_NUMBER() over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID) as RowNum
From NashvilleHousing
)
Delete
from RowNumCTE
where RowNum > 1



--Delete Unused Columns

Select *
From NashvilleHousing

Alter table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
Drop Column SaleDate