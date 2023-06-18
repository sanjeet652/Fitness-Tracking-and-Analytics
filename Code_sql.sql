-- Create Users table
CREATE TABLE Users (
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(255),
  password VARCHAR(255),
  email VARCHAR(255),
  gender VARCHAR(10),
  date_of_birth DATE,
  height DECIMAL(5,2),
  weight DECIMAL(5,2)
);

-- Create Exercises table
CREATE TABLE Exercises (
  exercise_id SERIAL PRIMARY KEY,
  exercise_name VARCHAR(255),
  description TEXT
);

-- Create Workouts table
CREATE TABLE Workouts (
  workout_id SERIAL PRIMARY KEY,
  user_id INT REFERENCES Users(user_id),
  workout_date DATE,
  duration INTERVAL
);

-- Create Workout Exercises table
CREATE TABLE WorkoutExercises (
  workout_exercise_id SERIAL PRIMARY KEY,
  workout_id INT REFERENCES Workouts(workout_id),
  exercise_id INT REFERENCES Exercises(exercise_id),
  sets INT,
  reps INT,
  weight DECIMAL(5,2)
);

-- Create Metrics table
CREATE TABLE Metrics (
  metric_id SERIAL PRIMARY KEY,
  workout_id INT REFERENCES Workouts(workout_id),
  calories_burned DECIMAL(8,2),
  distance_covered DECIMAL(8,2)
);


--Insert a new user:
INSERT INTO Users (username, password, email, gender, date_of_birth, height, weight)
VALUES ('john_doe', 'password123', 'john@example.com', 'male', '1990-01-01', 180, 75);


--Insert a new exercise:
INSERT INTO Exercises (exercise_name, description)
VALUES ('Running', 'Cardiovascular exercise that involves running at a steady pace.');


--Create a new workout for a user:
INSERT INTO Workouts (user_id, workout_date, duration)
VALUES (1, '2023-06-18', '00:45:00');


--Add exercises to a workout:
INSERT INTO WorkoutExercises (workout_id, exercise_id, sets, reps, weight)
VALUES (1, 1, 3, 10, 0);


--Calculate total calories burned and distance covered for a workout:
INSERT INTO Metrics (workout_id, calories_burned, distance_covered)
SELECT 1, SUM(sets * reps * weight * 0.000239006), 5.6
FROM WorkoutExercises
WHERE workout_id = 1;


--Generate a report of workout metrics for a specific user:
SELECT w.workout_date, m.calories_burned, m.distance_covered
FROM Workouts w
JOIN Metrics m ON w.workout_id = m.workout_id
WHERE w.user_id = 1;




--Retrieve all workouts for a specific user:
SELECT *
FROM Workouts
WHERE user_id = 1;


--Calculate the average duration of workouts for a specific user:
SELECT AVG(EXTRACT(epoch FROM duration)) / 60 AS avg_duration_minutes
FROM Workouts
WHERE user_id = 1;


--Calculate the total calories burned by a user across all workouts:
SELECT SUM(calories_burned) AS total_calories_burned
FROM Metrics
JOIN Workouts ON Metrics.workout_id = Workouts.workout_id
WHERE Workouts.user_id = 1;


--Retrieve the top 5 exercises performed by users based on the number of sets:
SELECT exercise_name, SUM(sets) AS total_sets
FROM WorkoutExercises
JOIN Exercises ON WorkoutExercises.exercise_id = Exercises.exercise_id
GROUP BY exercise_name
ORDER BY total_sets DESC
LIMIT 5;


--Calculate the average calories burned and distance covered per workout:
SELECT AVG(calories_burned) AS avg_calories_burned, AVG(distance_covered) AS avg_distance_covered
FROM Metrics;


--Retrieve the most recent workout for each user:
SELECT *
FROM Workouts w
WHERE workout_date = (
  SELECT MAX(workout_date)
  FROM Workouts
  WHERE user_id = w.user_id
);


--Rank users based on their total calories burned, using a window function:
SELECT user_id, total_calories_burned,
       RANK() OVER (ORDER BY total_calories_burned DESC) AS rank
FROM (
  SELECT w.user_id, SUM(m.calories_burned) AS total_calories_burned
  FROM Workouts w
  JOIN Metrics m ON w.workout_id = m.workout_id
  GROUP BY w.user_id
) AS subquery;


--Calculate the average calories burned per workout and compare it to the user's personal average, using a window function:
SELECT w.user_id, m.workout_id, m.calories_burned,
       AVG(m.calories_burned) OVER (PARTITION BY w.user_id) AS avg_calories_burned,
       CASE
         WHEN m.calories_burned > AVG(m.calories_burned) OVER (PARTITION BY w.user_id)
           THEN 'Above Average'
         WHEN m.calories_burned < AVG(m.calories_burned) OVER (PARTITION BY w.user_id)
           THEN 'Below Average'
         ELSE 'Average'
       END AS comparison
FROM Workouts w
JOIN Metrics m ON w.workout_id = m.workout_id;









