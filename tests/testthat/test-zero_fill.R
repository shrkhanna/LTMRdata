require(LTMRdata)
require(dplyr)

species <- c("Clupea pallasii", "Morone saxatilis", "Parophrys vetulus", "Sardinops sagax")

Data <- LTMRpilot(convert_lengths=TRUE, remove_unconverted_lengths=TRUE)

Data_species <- filter(Data, Taxa%in%species[1])

Data_species_correct <- filter(Data, Taxa%in%species[1] | is.na(Taxa))

Data_multspecies <- filter(Data, Taxa%in%species)

Data <- LTMRpilot(convert_lengths=TRUE, remove_unconverted_lengths=TRUE)

Data_filled<- zero_fill(Data, remove_unknown_lengths=FALSE)

Data_filled_univariate <- zero_fill(Data, remove_unknown_lengths=TRUE, univariate=TRUE)

Data_filled_univariate_species <- zero_fill(Data, species=species[1], remove_unknown_lengths=TRUE, univariate=TRUE)

Data_filled_univariate_multspecies <- zero_fill(Data, species=species, remove_unknown_lengths=TRUE, univariate=TRUE)

Data_filled_multivariate <- zero_fill(Data, remove_unknown_lengths=TRUE, univariate=FALSE)

test_that("zero_fill output has more rows and 0 counts than input data", {
  expect_gt(nrow(Data_filled), nrow(Data))
  expect_gt(nrow(Data_filled_univariate), nrow(Data))
  expect_gt(nrow(Data_filled_multivariate), nrow(Data))
  expect_gt(nrow(Data_filled_univariate_species), nrow(Data_species))
  expect_gt(nrow(Data_filled_univariate_multspecies), nrow(Data_multspecies))
  expect_gt(nrow(filter(Data_filled, Count==0)), nrow(filter(Data, Count==0)))
  expect_gt(nrow(filter(Data_filled_multivariate, Count==0)), nrow(filter(Data, Count==0)))
  expect_gt(nrow(filter(Data_filled_univariate, Count==0)), nrow(filter(Data, Count==0)))
  expect_gt(nrow(filter(Data_filled_univariate_species, Count==0)), nrow(filter(Data_species, Count==0)))
  expect_gt(nrow(filter(Data_filled_univariate_multspecies, Count==0)), nrow(filter(Data_multspecies, Count==0)))
})

test_that("remove_unknown_lengths=FALSE has most rows, followed by remove_unknown_lengths=TRUE & univariate=TRUE, and remove_unknown_lengths=TRUE & univariate=FALSE has the least rows", {
  expect_gt(nrow(Data_filled), nrow(Data_filled_univariate))
  expect_gt(nrow(Data_filled_univariate), nrow(Data_filled_multivariate))
})

test_that("All samples are retained in zero_fill output without removing unknown lengths", {
  expect_setequal(unique(Data_filled$SampleID), unique(Data$SampleID))
})

test_that("No unknown lengths remain after zero_fill with remove_unknown_lengths=TRUE", {
  expect_equal(nrow(filter(Data_filled_univariate, Length_NA_flag=="Unknown length")), 0)
  expect_equal(nrow(filter(Data_filled_multivariate, Length_NA_flag=="Unknown length")), 0)
  expect_equal(nrow(filter(Data_filled_univariate_species, Length_NA_flag=="Unknown length")), 0)
  expect_equal(nrow(filter(Data_filled_univariate_multspecies, Length_NA_flag=="Unknown length")), 0)
})

test_that("All Lats are between 37 ad 39 and all Longs are between -123 and -121", {
  expect_true(all((Data_filled$Latitude<39 & Data_filled$Latitude>37) | is.na(Data_filled$Latitude)))
  expect_true(all((Data_filled_univariate$Latitude<39 & Data_filled_univariate$Latitude>37) | is.na(Data_filled_univariate$Latitude)))
  expect_true(all((Data_filled_univariate_species$Latitude<39 & Data_filled_univariate_species$Latitude>37) | is.na(Data_filled_univariate_species$Latitude)))
  expect_true(all((Data_filled_univariate_multspecies$Latitude<39 & Data_filled_univariate_multspecies$Latitude>37) | is.na(Data_filled_univariate_multspecies$Latitude)))
  expect_true(all((Data_filled_multivariate$Latitude<39 & Data_filled_multivariate$Latitude>37) | is.na(Data_filled_multivariate$Latitude)))
  expect_true(all((Data_filled$Longitude<(-121) & Data_filled$Longitude>(-123)) | is.na(Data_filled$Longitude)))
  expect_true(all((Data_filled_univariate$Longitude<(-121) & Data_filled_univariate$Longitude>(-123)) | is.na(Data_filled_univariate$Longitude)))
  expect_true(all((Data_filled_univariate_species$Longitude<(-121) & Data_filled_univariate_species$Longitude>(-123)) | is.na(Data_filled_univariate_species$Longitude)))
  expect_true(all((Data_filled_univariate_multspecies$Longitude<(-121) & Data_filled_univariate_multspecies$Longitude>(-123)) | is.na(Data_filled_univariate_multspecies$Longitude)))
  expect_true(all((Data_filled_multivariate$Longitude<(-121) & Data_filled_multivariate$Longitude>(-123)) | is.na(Data_filled_multivariate$Longitude)))
})

test_that("Species filtering works correctly", {
  expect_setequal(unique(filter(Data_filled_univariate_species, !is.na(Taxa))$Taxa), species[1])
  expect_setequal(unique(filter(Data_filled_univariate_multspecies, !is.na(Taxa))$Taxa), species)
})

test_that("Error messages are functioning", {
  expect_error(test <- zero_fill(Data_species, remove_unknown_lengths=TRUE, univariate=TRUE),
               "There are no rows with NA Taxa")
  expect_message(test <- zero_fill(Data_species_correct, species=c("bla bla bla", species[1]), remove_unknown_lengths=TRUE, univariate=TRUE),
                 "These species were not present in your data: bla bla bla")
})
