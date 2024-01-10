-- This Project is a demostration of my cleaning data skills


--							Standrize Date							--


select *
from PortifolioSQL..NashvilleHousing

-- This should convert the existing dates from 2014-09-19 00:00:00.000 to 2014-09-19 but it didnt work for some reason
update PortifolioSQL..NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

-- Another workaround to make this work
Alter table PortifolioSQL..NashVilleHousing
Add SalesConverted Date

-- Add values for SalesConverted
update PortifolioSQL..NashvilleHousing
set SalesConverted = CONVERT(Date,SaleDate)


-- Populate Property Address

-- the idea behind this query is that we make an inner join by itself and as we find the rows that have the same ParcelID and blank Address
update a

set PropertyAddress =  isnull(a.PropertyAddress, b.PropertyAddress)
from [PortifolioSQL]..NashvilleHousing a
join [PortifolioSQL]..NashvilleHousing b
on
a.ParcelID = b.ParcelID and 
a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- Split the after the ','

select PropertyAddress as before_split,
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1) as before_delimiter
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))  as after_delimiter


from [PortifolioSQL]..NashvilleHousing




-- Split Owner Address and add it using Parasename and use replace to change from , to .
ALTER TABLE PortifolioSQL..NashVilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortifolioSQL..NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortifolioSQL..NashVilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortifolioSQL..NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortifolioSQL..NashVilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortifolioSQL..NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change Y and N to yes and no

update  PortifolioSQL..NashVilleHousing

set  SoldAsVacant = 'Yes'

where SoldAsVacant = 'Y'

update  PortifolioSQL..NashVilleHousing

set  SoldAsVacant = 'No'

where SoldAsVacant = 'N'

--remove duplicates
with Rowas as (
select * , row_number() over (partition by ParcelID,PropertyAddress,LegalReference,SaleDate,LegalReference  order by ParcelID) as row_n
from PortifolioSQL..NashVilleHousing)



select *
from Rowas
where row_n >= 2

-- remove unused columns

Alter Table PortifolioSQL.dbo.NashVilleHousing

drop column OwnerAddress,TaxDistrict,PropertyAddress
