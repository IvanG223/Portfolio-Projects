Select *
From PortfolioProject1..NashvilleHousing

--Standardize Date Format

Select SaleDate, Cast(SaleDate as date) As SaleDateConverted
From PortfolioProject1..NashvilleHousing

Select SaleDate, Convert(date, SaleDate) As SaleDateConverted
From PortfolioProject1..NashvilleHousing

Alter Table PortfolioProject1..NashvilleHousing
Alter Column SaleDate date


--Populating Property Address

Select *
From PortfolioProject1..NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

Select v1.ParcelID, v1.PropertyAddress, v2.ParcelID, v2.PropertyAddress, ISNULL(v1.PropertyAddress, v2.PropertyAddress)
From PortfolioProject1..NashvilleHousing v1
	Join PortfolioProject1..NashvilleHousing v2
	ON v1.ParcelID = v2.ParcelID
	AND v1.[UniqueID ] <> v2.[UniqueID ]
Where v1.PropertyAddress is null

Update v1
Set v1.PropertyAddress = ISNULL(v1.PropertyAddress, v2.PropertyAddress)
From PortfolioProject1..NashvilleHousing v1
	Join PortfolioProject1..NashvilleHousing v2
	ON v1.ParcelID = v2.ParcelID
	AND v1.[UniqueID ] <> v2.[UniqueID ]
Where v1.PropertyAddress is null


--Breaking Addresses Into Individual Columns

Select PropertyAddress
From PortfolioProject1..NashvilleHousing
--Where PropertyAddress is null

Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) As Address
, SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +2, Len(PropertyAddress)) As City
From PortfolioProject1..NashvilleHousing

Alter Table PortfolioProject1..NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update PortfolioProject1..NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter Table PortfolioProject1..NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update PortfolioProject1..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +2, Len(PropertyAddress))





Select OwnerAddress
From PortfolioProject1..NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.'), 3)
, Trim(Parsename(Replace(OwnerAddress, ',', '.'), 2))
, Trim(Parsename(Replace(OwnerAddress, ',', '.'), 1))
From PortfolioProject1..NashvilleHousing

Alter Table PortfolioProject1..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update PortfolioProject1..NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject1..NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update PortfolioProject1..NashvilleHousing
Set OwnerSplitCity = Trim(Parsename(Replace(OwnerAddress, ',', '.'), 2))

Alter Table PortfolioProject1..NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update PortfolioProject1..NashvilleHousing
Set OwnerSplitState = Trim(Parsename(Replace(OwnerAddress, ',', '.'), 1))


--Change Y And N To Yes Or No In SoldAsVacant Column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject1..NashvilleHousing

Update PortfolioProject1..NashvilleHousing
Set SoldAsVacant
= CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End


--Removing Duplicates

With RowNumCTE As(
Select *,
		ROW_NUMBER() Over(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order By
							UniqueID
							) row_num
From PortfolioProject1..NashvilleHousing
)
Select * --Delete Goes Here
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress


--Delete Unused/Old Columns

Alter Table PortfolioProject1..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject1..NashvilleHousing