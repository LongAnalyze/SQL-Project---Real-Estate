Select *
From TN_Housing;
	
--Populate Property Address
Select *
From TN_Housing
Order By ParcelID;
--Convert the Space to Null, so I can use IFNULL to populate the address
Update TN_Housing
Set PropertyAddress = NULL
Where PropertyAddress = '';
--Rerun this query to check if the populate address is corrected
Select hd.ParcelID, hd.PropertyAddress, hd2.ParcelID, hd2.PropertyAddress, IFNULL(hd.PropertyAddress,hd2.PropertyAddress)
From TN_Housing hd
Join TN_Housing hd2 
	On hd.ParcelID = hd2.ParcelID 
	AND hd."UniqueID " <> hd2 ."UniqueID " 
Where hd.PropertyAddress is null;


Update TN_Housing
Set PropertyAddress = IFNULL(hd.PropertyAddress,hd2.PropertyAddress)
From TN_Housing hd 
Join TN_Housing hd2 
	On hd.ParcelID = hd2.ParcelID 
	AND hd."UniqueID " <> hd2 ."UniqueID " 
Where hd.PropertyAddress is null;


--Break PropertyAddress into Address,City
Select PropertyAddress 
From TN_Housing;



Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS SplitAddress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LENGTH(PropertyAddress)) AS SplitCity
From TN_Housing;

--create new column as address and update the new split address
ALTER TABLE TN_Housing
ADD Address nvarchar(255);

Update TN_Housing
SET Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

--create new column as city and update the new split city
ALTER TABLE TN_Housing
ADD City nvarchar(255);

Update TN_Housing 
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LENGTH(PropertyAddress)) ;


--Change Y and N to YES/NO to Yes/No in Sold As Vacant COLUMN 
Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From TN_Housing th 
Group by SoldAsVacant 
Order by 2
;

Select SoldAsVacant,
	CASE When SoldAsVacant = 'YES' THEN 'Yes'
		 When SoldAsVacant = 'NO' Then 'No'
		 Else SoldAsVacant
		 END
From TN_Housing th ;

Update TN_Housing 
SET SoldAsVacant = CASE 
		 When SoldAsVacant = 'YES' THEN 'Yes'
		 When SoldAsVacant = 'NO' Then 'No'
		 Else SoldAsVacant
		 END;


--Remove Duplicates
WITH RowNumCTE AS(
Select *, ROW_NUMBER () OVER 
	(PARTITION BY ParcelID,
	 PropertyAddress,
	 SalePrice,
	 SaleDate,
	 LegalReference
	 ORDER BY "UniqueID "  
	 ) AS RowNumber
From TN_Housing
)

DELETE 
FROM RowNumCTE
Where RowNumber > 1;



--Delete unused columns

Select *
From TN_Housing;

ALTER TABLE TN_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, Bedrooms, FullBath, HalfBath;

--The purpose of cleaning the data is  to see where the property, its price, acerage, the value of the land/building
--This will create better information when we want to see where the house is worth and see how it will help us determine the house's values
--Also, we adjust the address to make it less messy and easier to identify the location of the property


