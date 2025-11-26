# small official python image
FROM python:3.10-slim

# set working directory
WORKDIR /app

# copy requirements file and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy project code 
COPY . .

# expose the port on which app runs 
EXPOSE 8080

# Start the app
CMD ["python", "app.py"]