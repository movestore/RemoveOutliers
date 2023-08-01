library('move2')

test_data <- test_data("input1.rds") #file must be move2!

test_that("happy path", {
  actual <- rFunction(data = test_data, maxspeed = 20, MBremove = FALSE, FUTUREremove = TRUE, accuracy_var = "eobs_horizontal_accuracy_estimate", minaccuracy = 30)
  expect_equal(nrow(actual), 99363)
})

test_that("happy path", {
  actual <- rFunction(data = test_data, maxspeed = NULL, MBremove = TRUE, FUTUREremove = FALSE, accuracy_var = NULL, minaccuracy = NULL)
  expect_equal(nrow(actual), 99668)
})

test_that("no data remain", {
  actual <- rFunction(data = test_data, maxspeed = 0.1, MBremove = FALSE, FUTUREremove = TRUE, accuracy_var = "eobs_horizontal_accuracy_estimate", minaccuracy = 0.1)
  expect_null(actual)
})

#no date with visible FALSE