SELECT * 
FROM layoffs ;

#romve duplicates
#standardize the data
#null values and blank values
#remove any cols 

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging ;

INSERT layoffs_staging
SELECT * 
FROM layoffs;


SELECT * , ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) 
FROM layoffs_staging ;


WITH duplicate_cte AS (
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,
			location,
			industry,
			total_laid_off,
			percentage_laid_off,
			`date`,
            stage,
            country,
            funds_raised_millions
            )as row_num 
FROM layoffs_staging 
)

SELECT *
FROM duplicate_cte 
WHERE row_num >1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

INSERT
INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,
			location,
			industry,
			total_laid_off,
			percentage_laid_off,
			`date`,
            stage,
            country,
            funds_raised_millions
            )as row_num 
FROM layoffs_staging 
;

DELETE  
FROM layoffs_staging2
WHERE row_num>1;


SELECT *  
FROM layoffs_staging2
;

-- standardizing
SELECT company,TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT distinct(industry)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry like 'Crypto%';



SELECT  DISTINCT location 
FROM layoffs_staging2
ORDER BY location;




SELECT  DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country = 'United States'
WHERE country like 'United States%';


SELECT DISTINCT country , TRIM(TRAILING '.' FROM country )
FROM layoffs_staging2
ORDER BY 1;


SELECT `date`,
str_to_date(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

SELECT `date` 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL		#ONE OR MORE NULL COLS ARE USELESS
AND percentage_laid_off IS NULL;



SELECT   * 
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT   * 
FROM layoffs_staging2
WHERE company = "Airbnb";


UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE  company  like 'Airbnb';

SELECT t1.industry , t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t1.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;
   
   
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';  

SELECT DISTINCT industry , country ,company
FROM layoffs_staging2;

SELECT   * 
FROM layoffs_staging2
WHERE company = "Bally's Interactive";

SELECT   * 
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL		#ONE OR MORE NULL COLS ARE USELESS
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL		#ONE OR MORE NULL COLS ARE USELESS
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
