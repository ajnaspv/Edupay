from django.contrib.auth.models import User
from django.db import models

# Create your models here.
class staff(models.Model):
    name=models.CharField(max_length=20)
    email=models.CharField(max_length=30)
    phone=models.BigIntegerField(13)
    # post=models.CharField(max_length=20)
    LOGIN=models.ForeignKey(User,on_delete=models.CASCADE)

class course(models.Model):
    department=models.CharField(max_length=20)
    course=models.CharField(max_length=30)
    details=models.CharField(max_length=100)


class student(models.Model):
    COURSE = models.ForeignKey(course,on_delete=models.CASCADE)
    email = models.CharField(max_length=200)
    phone = models.BigIntegerField(20)
    name = models.CharField(max_length=20)
    batch = models.CharField(max_length=20)
    semester = models.CharField(max_length=20)
    LOGIN = models.ForeignKey(User,on_delete=models.CASCADE)
    status = models.CharField(max_length=20)
    adm_no=models.CharField(max_length=20)
    photo=models.FileField(null=True,blank=True)

class Fee(models.Model):
    COURSE = models.ForeignKey(course,on_delete=models.CASCADE)
    semester = models.CharField(max_length=20)
    fee = models.FloatField(20)
    batch = models.IntegerField(20)

class Feetype(models.Model):
    FEE = models.ForeignKey(Fee,on_delete=models.CASCADE)
    title = models.CharField(max_length=50)
    fee = models.FloatField(20)

class payments(models.Model):
    FEE=models.ForeignKey(Fee,on_delete=models.CASCADE)
    STUDENT=models.ForeignKey(student,on_delete=models.CASCADE)
    date=models.DateField()
    status=models.CharField(max_length=100)
    totalamount=models.CharField(max_length=200)
    fineamount=models.IntegerField()

class Alert(models.Model):
    FEE = models.ForeignKey(Fee,on_delete=models.CASCADE)
    fromdate = models.DateField()
    todate = models.DateField()
    note = models.CharField(max_length=500)
    finedate = models.DateField()
    fineamount = models.FloatField(20)
    STAFF = models.ForeignKey(staff,on_delete=models.CASCADE,null=True)
    TYPE = models.CharField(max_length=20)


class Alertsub(models.Model):
    STUDENT = models.ForeignKey(student,on_delete=models.CASCADE)
    ALERT = models.ForeignKey(Alert,on_delete=models.CASCADE)
    status = models.CharField(max_length=200,default='pending')




class Feedback(models.Model):
    STUDENT = models.ForeignKey(student,on_delete=models.CASCADE)
    feedback = models.CharField(max_length=500)
    date = models.DateField()


class Concession(models.Model):
    STUDENT = models.ForeignKey(student, on_delete=models.CASCADE)
    semester = models.CharField(max_length=20)
    concession_fee=models.IntegerField()

class Complaints(models.Model):
    title = models.CharField(max_length=200)
    category = models.CharField(max_length=200)
    description = models.TextField()
    status = models.CharField(max_length=200)
    reply = models.TextField()
    date = models.DateField()
    STUDENT = models.ForeignKey(student, on_delete=models.CASCADE)

class complaintsub(models.Model):
    COMPLAINTS = models.ForeignKey(Complaints, on_delete=models.CASCADE)
    image = models.CharField(max_length=200)

class chatbot(models.Model):
    STUDENT = models.ForeignKey(student, on_delete=models.CASCADE,null=True)
    date = models.DateField()
    message = models.TextField()
    type = models.CharField(max_length=50)



