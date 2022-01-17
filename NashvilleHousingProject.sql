
/*
Cleaning Data in SQL Queries
*/


Select *
From [Sql project]..[Nashville Housing ]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate) -- convert is  used here to convert datetime (saledate) into date using date  
From [Sql project]..[Nashville Housing ]


Update [Sql project]..[Nashville Housing ] --- updating directly it in the table
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE [Sql project]..[Nashville Housing ] -- alter is used here to create a new column 
Add SaleDateConverted Date;

Update [Sql project]..[Nashville Housing ]        --after creating a column in alter table now updating it in the database
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------



-- Populate Property Address data

Select *
From [Sql project]..[Nashville Housing ]
--Where PropertyAddress is null
order by ParcelID

--many Property address are null in the table to insert address in them Self JOIN is used here 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Sql project]..[Nashville Housing ]a
JOIN [Sql project]..[Nashville Housing ]b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--updating the address in the first table by using self join with the same table
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Sql project]..[Nashville Housing ] a
JOIN [Sql project]..[Nashville Housing ] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From [Sql project]..[Nashville Housing ]
--Where PropertyAddress is null
--order by ParcelID

--SUBSTRING(string or column name that have string, start position , length)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address --this is for address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address --this is for city

From [Sql project]..[Nashville Housing ]

--for address creating new column in the table and updating it in the table
ALTER TABLE [Sql project]..[Nashville Housing ]
Add PropertySplitAddress Nvarchar(255);

Update [Sql project]..[Nashville Housing ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


--for city creating new column in the table and updating it in the table
ALTER TABLE [Sql project]..[Nashville Housing ]
Add PropertySplitCity Nvarchar(255);

Update [Sql project]..[Nashville Housing ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From  [Sql project]..[Nashville Housing ]


--easy way for seperating any strings that have period (.) in them


Select OwnerAddress
From  [Sql project]..[Nashville Housing ]

--Replace(string/column name, old string , new string) here we have converted ',' to '.' so that we can use parsename
--PARSENAME(string/column name, 3) it get the end part 1st of the string that is why is written in reverse order

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From  [Sql project]..[Nashville Housing ]


--for Splited address
ALTER TABLE [Sql project]..[Nashville Housing ]
Add OwnerSplitAddress Nvarchar(255);

Update [Sql project]..[Nashville Housing ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

--for Splited city
ALTER TABLE [Sql project]..[Nashville Housing ]
Add OwnerSplitCity Nvarchar(255);

Update [Sql project]..[Nashville Housing ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


--for Splited state
ALTER TABLE [Sql project]..[Nashville Housing ]
Add OwnerSplitState Nvarchar(255);

Update [Sql project]..[Nashville Housing ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [Sql project]..[Nashville Housing ]




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Sql project]..[Nashville Housing ]
Group by SoldAsVacant
order by 2


--case is used to change the 'y' and 'n' to yes and no in the table
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Sql project]..[Nashville Housing ]


Update [Sql project]..[Nashville Housing ]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- find Duplicates

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

From [Sql project]..[Nashville Housing ]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- REMOVE duplicates by this

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

From [Sql project]..[Nashville Housing ]
--order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


Select *
From [Sql project]..[Nashville Housing ]




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From [Sql project]..[Nashville Housing ]


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO