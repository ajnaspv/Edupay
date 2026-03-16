import random
import datetime
import smtplib
from django.contrib.auth import authenticate, logout, login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User, Group
from django.db.models import Q, Sum
from django.http import HttpResponse, JsonResponse
from django.shortcuts import render, redirect

# Create your views here.
from django.views.decorators.cache import never_cache

from myapp.models import course, Fee, Alert, Feedback, staff, student, payments, Concession, Feetype, Complaints, \
    chatbot, complaintsub, Alertsub

print(make_password('9746132365'))
#index page
def index(request):
    return render(request, 'index.html')
def loginn(request):
    return render(request,'Admin/login.html')
def login_submit(request):
    Username =request.POST['textfield']
    Password =request.POST['textfield2']
    data = authenticate(username=Username,password=Password)
    if data is not None:
        request.session['p'] = Password
        login(request,data)
        if data.is_superuser:
            request.session['type'] = "admin"
            return HttpResponse(
                "<script>alert('Login Success');window.location='/home'</script>")

        if data.groups.filter(name="staff").exists():
            request.session['type'] = "staff"
            return HttpResponse(
                "<script>alert('Login Success');window.location='/StaffHome'</script>")

    else:
        return HttpResponse("<script>alert('Invalid login credentials');window.location='/'</script>")

@login_required(login_url='/')
@never_cache
def addcourse(request):
    if request.session['type'] != "admin":
        return redirect('/')
    return render(request,'Admin/Addcourse.html')

def logouts(request):
    logout(request)
    return HttpResponse("<script>alert('Logouted Successfully');window.location='/'</script>")

def addcourse_submit(request):
    Department =request.POST['select']
    Course =request.POST['textfield']
    Details =request.POST['textarea']
    if course.objects.filter(department=Department,course=Course).exists():
        return HttpResponse("<script>alert('Course Already Exist');window.location='/viewcourse'</script>")

    obj=course()
    obj.department=Department
    obj.course=Course
    obj.details=Details
    obj.save()

    return HttpResponse("<script>alert('Course Added Successfully');window.location='/viewcourse'</script>")

@login_required(login_url='/')
@never_cache
def semchange(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = course.objects.all()
    data2 = range(2023, int(datetime.datetime.now().year) + 2)
    return render(request,'Admin/semchange.html',{'data':data,'data2':data2})

def changesem_submit(request):
    Batch = request.POST['select']
    Course = request.POST['select1']
    old_sem = request.POST['select2']
    new_sem = request.POST['select3']
    student.objects.filter(batch=Batch,COURSE=Course,semester=old_sem).update(semester=new_sem)

    return HttpResponse("<script>alert('Sem Changed Successfully');window.location='/viewstudent'</script>")

@login_required(login_url='/')
@never_cache
def addfee(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data =course.objects.all()
    data2 = range(2023,int(datetime.now().year) + 2)
    return render(request,'Admin/Addfee.html',{'data':data,'data2':data2})
def addfee_submit(request):
    print(request.POST,"ok")
    Semester =request.POST['select']
    Batch =request.POST['select2']
    Feee =request.POST['textfield']
    fee = request.POST.getlist('fee')
    title =request.POST.getlist('title')

    if Fee.objects.filter(semester=Semester,batch=Batch,COURSE_id=request.POST['select3']).exists():
        return HttpResponse("<script>alert('Fee Already Exist');window.location='/viewfee'</script>")
    obj=Fee()
    obj.semester=Semester
    obj.batch=Batch
    obj.fee=Feee
    obj.COURSE_id = request.POST['select3']
    obj.save()

    for i in range(0,len(fee)):
        obj2 = Feetype()
        obj2.title = title[i]
        obj2.fee = fee[i]
        obj2.FEE_id = obj.id
        obj2.save()

    return HttpResponse("<script>alert('Fee Added Successfully');window.location='/viewfee'</script>")

@login_required(login_url='/')
@never_cache
def addfeealert(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = course.objects.all()
    data2 =Fee.objects.all()
    return render(request, 'Admin/AddfeeAlert.html',{'data':data,'data2':data2})

def addfeealert_submit(request):
    try:
        Course = request.POST['select']
        Semester = request.POST['select2']
        Note = request.POST['textfield']
        Fine_amount = request.POST['textfield2']
        Todate = request.POST['datefield']
        Fine_date = request.POST['datefield2']
        fee_id = request.POST.get('select3', '').strip()

        # If fee_id not provided, try to find a matching Fee for the course+semester
        fee_obj = None
        if not fee_id:
            fee_obj = Fee.objects.filter(semester=Semester, COURSE_id=Course).first()
            if not fee_obj:
                return HttpResponse(
                    "<script>alert('No fee available for selected course and semester');window.location='/addfeealert'</script>")
        else:
            try:
                fee_obj = Fee.objects.get(id=fee_id)
            except Fee.DoesNotExist:
                return HttpResponse("<script>alert('Selected fee not found');window.location='/addfeealert'</script>")

        if Fine_amount:
            try:
                fine_num = float(Fine_amount)
            except Exception:
                return HttpResponse("<script>alert('Invalid fine amount');window.location='/addfeealert'</script>")

            try:
                fee_num = float(fee_obj.fee)
            except Exception:
                fee_num = None

            # if fee_num is not None and fine_num >= fee_num:
            #     return HttpResponse(
            #         "<script>alert('Fine amount must be less than the fee amount');window.location='/addfeealert'</script>")

        obj = Alert()
        obj.FEE_id = fee_obj.id
        obj.todate = Todate
        obj.note = Note
        obj.finedate = Fine_date
        obj.fineamount = Fine_amount
        obj.TYPE = "admin"
        obj.fromdate = datetime.now().date()
        obj.save()


        studdata = student.objects.filter(batch=fee_obj.batch,COURSE=fee_obj.COURSE_id,semester=fee_obj.semester)
        for i in studdata:
            obj2 = Alertsub()
            obj2.STUDENT_id = i.id
            obj2.ALERT_id = obj.id
            obj2.save()

        return HttpResponse("<script>alert('Fee Alert Added Successfully');window.location='/viewfeealert'</script>")
    except Exception as e:
        return HttpResponse(
            "<script>alert('Fine amount must be less than the fee amount or 0');window.location='/addfeealert'</script>")


@login_required(login_url='/')
@never_cache
def addstaff(request):
    if request.session['type'] != "admin":
        return redirect('/')
    return render(request,'Admin/AddStaff.html')
def addstaff_submit(request):
    try:
        Name =request.POST['textfield']
        Email =request.POST['textfield2']
        Phone =request.POST['textfield3']
        # Post =request.POST['textfield4']
        password = str(random.randint(10000,99999))

        if User.objects.filter(username=Email).exists():
            return HttpResponse("<script>alert('Email Already Exist');window.location='/viewstaff'</script>")
        if staff.objects.filter(email=Email).exists():
            return HttpResponse("<script>alert('Staff Already Exist with this mail');window.location='/viewstaff'</script>")


        # ✨ Python Email Codeimport smtplib

        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart

        # ✅ Gmail credentials (use App Password, not real password)
        sender_email = "mail.edupay@gmail.com"
        receiver_email = Email  # change to actual recipient
        app_password = "tybc lbmz grvl daqh"  # App Password from Google
        pwd = password  # Example password to send

        # Setup SMTP
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(sender_email, app_password)

        # Create the email
        msg = MIMEMultipart("alternative")
        msg["From"] = sender_email
        msg["To"] = receiver_email
        msg["Subject"] = "🔑 Your Edupay Website Password"

        # Plain text (backup)
        # text = f"""
        # Hello,

        # Your password for Edupay Website is: {pwd}

        # Please keep it safe and do not share it with anyone.
        # """

        # HTML (attractive)
        html = f"""
        <html>
          <body style="font-family: Arial, sans-serif; color: #333;">
            <h2 style="color:#2c7be5;">🔑 Edupay Website</h2>
            <p>Hello,</p>
            <p>Your password is:</p>
            <p style="padding:10px; background:#f4f4f4; 
                      border:1px solid #ddd; 
                      display:inline-block;
                      font-size:18px;
                      font-weight:bold;
                      color:#2c7be5;">
              {pwd}
            </p>
            <p>Please keep it safe and do not share it with anyone.</p>
            <hr>
            <small style="color:gray;">This is an automated email from Edupay.</small>
          </body>
        </html>
        """

        # Attach both versions
        # msg.attach(MIMEText(text, "plain"))
        msg.attach(MIMEText(html, "html"))

        # Send email
        server.send_message(msg)
        print("✅ Email sent successfully!")

        # Close connection
        server.quit()


        obj1 = User()
        obj1.username = Email
        obj1.password = make_password(password)
        obj1.save()
        obj1.groups.add(Group.objects.get(name="staff"))
        obj=staff()
        obj.name=Name
        obj.email=Email
        obj.phone=Phone
        # obj.post=Post
        obj.LOGIN = obj1
        obj.save()
    except:
        pass
    return HttpResponse("<script>alert('Staff Added Successfully');window.location='/viewstaff'</script>")

@login_required(login_url='/')
@never_cache
def addstudent(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = course.objects.all()
    data2 = range(2023, int(datetime.now().year) + 2)
    return render(request,'Admin/AddStudent.html',{'data':data,'data2':data2})
def addstudent_submit(request):
    Name =request.POST['textfield']
    Email =request.POST['textfield2']
    Phone =request.POST['textfield3']
    Adm_no =request.POST['textfield4']
    Batch =request.POST['select']
    Semester =request.POST['select2']
    Course =request.POST['select3']

    if student.objects.filter(email=Email).exists():
        return HttpResponse("<script>alert('Student Already Exist');window.location='/viewstudent'</script>")
    if student.objects.filter(phone=Phone).exists():
        return HttpResponse("<script>alert('Student Already Exist');window.location='/viewstudent'</script>")

    # password = str(random.randint(10000, 99999))

    # ✨ Python Email Codeimport smtplib

    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    # ✅ Gmail credentials (use App Password, not real password)
    sender_email = "mail.edupay@gmail.com"
    receiver_email = Email  # change to actual recipient
    app_password = "tybc lbmz grvl daqh"  # App Password from Google
    pwd = "Student Account registered successfully"  # Example password to send

    # Setup SMTP
    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls()
    server.login(sender_email, app_password)

    # Create the email
    msg = MIMEMultipart("alternative")
    msg["From"] = sender_email
    msg["To"] = receiver_email
    msg["Subject"] = "Student Registration Succesfull"

    # Plain text (backup)
    # text = f"""
    # Hello,

    # Your password for Edupay Website is: {pwd}

    # Please keep it safe and do not share it with anyone.
    # """

    # HTML (attractive)
    html = f"""
    <html>
      <body style="font-family: Arial, sans-serif; color: #333;">
        <h2 style="color:#2c7be5;">Edupay</h2>
        <p>Hello,</p>
        <p>Your welcome to our app:</p>
        <p style="padding:10px; background:#f4f4f4; 
                  border:1px solid #ddd; 
                  display:inline-block;
                  font-size:18px;
                  font-weight:bold;
                  color:#2c7be5;">
          {pwd}
        </p>
        <p>Install app and login with your mobile number</p>
        <hr>
        <small style="color:gray;">This is an automated email from Edupay System.</small>
      </body>
    </html>
    """

    # Attach both versions
    # msg.attach(MIMEText(text, "plain"))
    msg.attach(MIMEText(html, "html"))

    # Send email
    server.send_message(msg)
    print("✅ Email sent successfully!")

    # Close connection
    server.quit()

    obj1 = User()
    obj1.username = Email
    obj1.password = make_password(Phone)
    obj1.save()
    obj1.groups.add(Group.objects.get(name="student"))

    obj=student()
    obj.name=Name
    obj.email=Email
    obj.phone=Phone
    obj.batch=Batch
    obj.semester=Semester
    obj.COURSE_id=Course
    obj.LOGIN = obj1
    obj.adm_no=Adm_no
    obj.status="Active"
    obj.save()

    return HttpResponse("<script>alert('Student Added Successfully');window.location='/viewstudent'</script>")

@login_required(login_url='/')
@never_cache
def changepassword(request):
    if request.session['type'] != "admin":
        return redirect('/')
    return render(request,'Admin/change password.html')
def changepassword_submit(request):
    Current_Password =request.POST['textfield']
    New_Password =request.POST['textfield2']
    Confirm_Password =request.POST['textfield3']
    if str(request.session['p']) == Current_Password:
        User.objects.filter(id=request.user.id).update(password=make_password(New_Password))
        return HttpResponse("<script>alert('Password Changed Successfully');window.location='/home'</script>")
    return HttpResponse("<script>alert('Current password does not match');window.location='/changepassword'</script>")

@login_required(login_url='/')
@never_cache
def editcourse(request,id):
    if request.session['type'] != "admin":
        return redirect('/')
    data = course.objects.get(id=id)
    request.session['id'] = id
    return render(request,'Admin/EditCourse.html',{'data':data})
def editcourse_submit(request):
    Department =request.POST['select']
    Course =request.POST['textfield']
    Details =request.POST['textarea']
    course.objects.filter(id= request.session['id']).update(department=Department,course=Course,details=Details)

    return HttpResponse("<script>alert('Course Edited Successfully');window.location='/viewcourse'</script>")


@login_required(login_url='/')
@never_cache
def editfee(request,id):
    if request.session['type'] != "admin":
        return redirect('/')
    data=Fee.objects.get(id=id)
    data2= course.objects.all()
    data3 = Feetype.objects.filter(FEE=id)
    request.session['id'] = id
    return render(request,'Admin/Editfee.html',{'data':data,'data2':data2,'data3':data3})
def editfee_submit(request):

    Feee =request.POST['textfield']

    Fee.objects.filter(id= request.session['id']).update(fee=Feee)

    fee = request.POST.getlist('fee')
    title = request.POST.getlist('title')
    id = request.POST.getlist('id')

    for i in range(0, len(fee)):
        try:
            if fee[i] != "" and title[i] != "":
                if str(id[i]) == "0":
                    obj2 = Feetype()
                    obj2.title = title[i]
                    obj2.fee = fee[i]
                    obj2.FEE_id = request.session['id']
                    obj2.save()
                else:
                    obj2 = Feetype.objects.get(id=id[i])
                    obj2.title = title[i]
                    obj2.fee = fee[i]
                    obj2.save()
            if id[i] == "" and title[i] != "":
                obj2 = Feetype()
                obj2.title = title[i]
                obj2.fee = fee[i]
                obj2.FEE_id = request.session['id']
                obj2.save()
        except Exception as e:
            print(e,"Error")
            obj2 = Feetype()
            obj2.title = title[i]
            obj2.fee = fee[i]
            obj2.FEE_id = request.session['id']
            obj2.save()

    return HttpResponse("<script>alert('Fee Edited Successfully');window.location='/viewfee'</script>")


def removefee(request,id):
    feedetails = Fee.objects.filter(id=request.session['id'])
    total = int(feedetails[0].fee) - int(Feetype.objects.get(id=id).fee)
    feedetails.update(fee = total)
    Feetype.objects.get(id=id).delete()
    return HttpResponse(f"<script>alert('Fee Removed Successfully');window.location='/editfee/{request.session['id']}'</script>")


@login_required(login_url='/')
@never_cache
def editfeealert(request,id):
    if request.session['type'] != "admin":
        return redirect('/')
    data = Alert.objects.get(id=id)
    request.session['id'] = id
    return render(request, 'Admin/EditFeeAlert.html',{'data':data})
def editfeealert_submit(request):

    Note =request.POST['textfield']
    Fine_amount =request.POST['textfield2']
    Todate =request.POST['datefield']
    Fine_date =request.POST['datefield2']
    Alert.objects.filter(id=request.session['id']).update(note=Note,todate=Todate,finedate=Fine_date,fineamount=Fine_amount)

    return HttpResponse("<script>alert('Fee Alert Edited Successfully');window.location='/viewfeealert'</script>")

@login_required(login_url='/')
@never_cache
def editstaff(request,id):
    if request.session['type'] != "admin":
        return redirect('/')
    data = staff.objects.get(id=id)
    request.session['id'] = id
    return render(request,'Admin/EditStaff.html',{'data':data})
def editstaff_submit(request):
    Name =request.POST['textfield']
    Email =request.POST['textfield2']
    Phone =request.POST['textfield3']
    # Post =request.POST['textfield4']
    staff.objects.filter(id = request.session['id']).update(name=Name,email=Email,phone=Phone)

    return HttpResponse("<script>alert('Staff Edited Successfully');window.location='/viewstaff'</script>")

@login_required(login_url='/')
@never_cache
def editstudent(request,id):
    if request.session['type'] != "admin":
        return redirect('/')
    data= student.objects.get(id=id)
    request.session['id'] = id
    data2= course.objects.filter()
    data3 = range(2023, int(datetime.now().year) + 2)
    return render(request,'Admin/EditStudent.html',{'data':data,'data2':data2,'data3':data3})
def editstudent_submit(request):
    Name=request.POST['textfield']
    Email =request.POST['textfield2']
    Phone = request.POST['textfield3']
    Batch = request.POST['select']
    # Semester =request.POST['select2']
    Course = request.POST['select3']
    Adm_no=request.POST['textfield4']
    Status = request.POST['textfield5']
    student.objects.filter(id=request.session['id']).update(name=Name,batch=Batch, email=Email, phone=Phone, COURSE=Course,adm_no=Adm_no,status=Status)

    return HttpResponse("<script>alert('Student Edited Successfully');window.location='/viewstudent'</script>")
#
#
# def forgotpassword(request):
#     return render(request,'Admin/FORGOT PAASWORD.html')
# def forgotpassword_submit(request):
#     OTP = request.POST['textfield']
#
#     return HttpResponse("ok")
#
#
# def forgotpasswordchange(request):
#     return render(request,'Admin/forgotpassword_change.html')
# def forgotpasswordchange_submit(request):
#     Confirm_Password = request.POST['textfield']
#     print(Confirm_Password)
#     return HttpResponse("ok")
#
#
# def forgotpasswordemail(request):
#     return render(request,'Admin/forgotpassword_email.html')
# def forgotpasswordemail_submit(request):
#     Email =request.POST['textfield']
#     print(Email)
#     return HttpResponse("ok")
#






from django.shortcuts import render, redirect
from .models import payments, course, student, Fee
from django.http import JsonResponse
from django.db.models import Sum, Count, Q
import json
from datetime import datetime

@login_required(login_url='/')
@never_cache
def payment(request):
    if request.session.get('type') != "admin":
        return redirect('/')

    # Get all payments with related data
    data = payments.objects.select_related('STUDENT', 'STUDENT__COURSE', 'FEE').all()

    # Get distinct courses for filter
    courses = course.objects.all()

    # Get distinct batches from students
    batches = student.objects.values_list('batch', flat=True).distinct().order_by('batch')

    # Get distinct semesters from students
    semesters = student.objects.values_list('semester', flat=True).distinct().order_by('semester')

    # Prepare payment data as JSON for JavaScript
    payment_json = []
    for payment in data:
        payment_json.append({
            'id': payment.id,
            'student_name': payment.STUDENT.name,
            'course': payment.STUDENT.COURSE.course,
            'department': payment.STUDENT.COURSE.department,
            'batch': payment.STUDENT.batch,
            'semester': payment.STUDENT.semester,
            'totalamount': float(payment.totalamount) if payment.totalamount else 0,
            'fineamount': payment.fineamount,
            'date': payment.date.strftime('%Y-%m-%d') if payment.date else '',
            'status': payment.status
        })

    context = {
        'data': data,
        'courses': courses,
        'batches': batches,
        'semesters': semesters,
        'payment_json': json.dumps(payment_json)
    }
    return render(request, 'Admin/payment.html', context)


def generate_payment_report(request):
    if request.method == 'POST':
        # Get filter parameters
        course_id = request.POST.get('course')
        batch = request.POST.get('batch')
        semester = request.POST.get('semester')
        date_range = request.POST.get('date_range')
        status = request.POST.get('status')

        # Start with base queryset
        payments_qs = payments.objects.select_related('STUDENT', 'STUDENT__COURSE', 'FEE').all()

        # Apply filters
        if course_id and course_id.strip():
            payments_qs = payments_qs.filter(STUDENT__COURSE_id=course_id)

        if batch and batch.strip():
            payments_qs = payments_qs.filter(STUDENT__batch=batch)

        if semester and semester.strip():
            payments_qs = payments_qs.filter(STUDENT__semester=semester)

        if status and status.strip():
            payments_qs = payments_qs.filter(status__icontains=status)

        if date_range and date_range.strip():
            # Parse date range (format: "YYYY-MM-DD to YYYY-MM-DD")
            try:
                start_date, end_date = date_range.split(' to ')
                payments_qs = payments_qs.filter(date__range=[start_date, end_date])
            except:
                pass

        # Calculate statistics
        stats = payments_qs.aggregate(
            total_collected=Sum('totalamount', filter=Q(status__icontains='paid')),
            total_fine=Sum('fineamount'),
            paid_count=Count('id', filter=Q(status__icontains='paid')),
            pending_count=Count('id', filter=Q(status__icontains='pending')),
            failed_count=Count('id', filter=Q(status__icontains='failed'))
        )

        # Get unique students count
        unique_students = payments_qs.values('STUDENT').distinct().count()

        # Prepare report data
        report_data = {
            'filters': {
                'course': course_id,
                'batch': batch,
                'semester': semester,
                'date_range': date_range,
                'status': status
            },
            'statistics': {
                'total_collected': float(stats['total_collected'] or 0),
                'total_fine': float(stats['total_fine'] or 0),
                'paid_count': stats['paid_count'] or 0,
                'pending_count': stats['pending_count'] or 0,
                'failed_count': stats['failed_count'] or 0,
                'total_payments': payments_qs.count(),
                'unique_students': unique_students
            },
            'payments': [
                {
                    'student_name': p.STUDENT.name,
                    'course': p.STUDENT.COURSE.course,
                    'department': p.STUDENT.COURSE.department,
                    'batch': p.STUDENT.batch,
                    'semester': p.STUDENT.semester,
                    'amount': float(p.totalamount or 0),
                    'fine': p.fineamount,
                    'date': p.date.strftime('%Y-%m-%d'),
                    'status': p.status
                }
                for p in payments_qs
            ]
        }

        return JsonResponse(report_data)

    return JsonResponse({'error': 'Invalid request method'}, status=400)


def get_filter_options(request):
    """API endpoint to get filter options dynamically"""
    if request.method == 'GET':
        courses = list(course.objects.values('id', 'course', 'department'))
        batches = list(student.objects.values_list('batch', flat=True).distinct().order_by('batch'))
        semesters = list(student.objects.values_list('semester', flat=True).distinct().order_by('semester'))

        return JsonResponse({
            'courses': courses,
            'batches': batches,
            'semesters': semesters
        })

    return JsonResponse({'error': 'Invalid request method'}, status=400)


def get_payment_summary(request):
    """API endpoint to get payment summary statistics"""
    if request.method == 'GET':
        # Get overall statistics
        total_paid = payments.objects.filter(status__icontains='paid').aggregate(
            total=Sum('totalamount')
        )['total'] or 0

        total_fine = payments.objects.aggregate(
            total=Sum('fineamount')
        )['total'] or 0

        pending_amount = payments.objects.filter(status__icontains='pending').aggregate(
            total=Sum('totalamount')
        )['total'] or 0

        paid_count = payments.objects.filter(status__icontains='paid').count()
        total_students = student.objects.count()

        # Get monthly summary for chart
        monthly_data = []
        for month in range(1, 13):
            month_payments = payments.objects.filter(
                date__month=month,
                date__year=datetime.now().year,
                status__icontains='paid'
            ).aggregate(total=Sum('totalamount'))['total'] or 0
            monthly_data.append(float(month_payments))

        return JsonResponse({
            'total_paid': float(total_paid),
            'total_fine': float(total_fine),
            'pending_amount': float(pending_amount),
            'paid_count': paid_count,
            'total_students': total_students,
            'monthly_data': monthly_data
        })

    return JsonResponse({'error': 'Invalid request method'}, status=400)

@login_required(login_url='/')
@never_cache
def rejectreason(request):
    if request.session['type'] != "admin":
        return redirect('/')
    return render(request,'Admin/rejectreason.html')
def rejectreason_submit(request):
    Reason =request.POST['textfield']
    print(Reason)
    return HttpResponse("ok")

@login_required(login_url='/')
@never_cache
def viewcourse(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data=course.objects.all()
    return render(request,'Admin/viewcourse.html',{'data':data})


@login_required(login_url='/')
@never_cache
def viewconcession(request,id):
    if request.session['type'] != "admin":
        return redirect('/')
    request.session['studid'] = id
    data = Concession.objects.filter(STUDENT_id=id)
    return render(request, 'Admin/viewconcession.html', {'data': data, "sid":id})
def removeconcession(request,id):
    if request.session['type'] != "admin":
        return redirect('/')
    Concession.objects.get(id=id).delete()
    sid=request.session['studid']
    return HttpResponse("<script>alert('Concession Removed Successfully');window.location='/viewconcession/"+sid+"'</script>")


@login_required(login_url='/')
@never_cache
def viewfee(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = Fee.objects.all()
    return render(request,'Admin/viewfee.html',{'data':data})


@login_required(login_url='/')
@never_cache
def viewfeealert(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = Alert.objects.all()
    return render(request,'Admin/viewfeealert.html',{'data':data})


@login_required(login_url='/')
@never_cache
def viewfeedback(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = Feedback.objects.all()
    return render(request,'Admin/viewfeedback.html',{'data':data})


@login_required(login_url='/')
@never_cache
def viewstaff(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = staff.objects.all()
    return render(request,'Admin/viewstaff.html',{'data':data})

@login_required(login_url='/')
@never_cache
def viewstudent(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = student.objects.filter(Q(status="Active") |Q(status="Inactive") )
    return render(request,'Admin/viewstudent.html',{'data':data})

@login_required(login_url='/')
@never_cache
def viewstudentverify(request):
    if request.session['type'] != "admin":
        return redirect('/')
    data = student.objects.filter(status="pending")
    return render(request,'Admin/viewstudentandverify.html',{'data':data})

@login_required(login_url='/')
@never_cache
def addconcession(request,id):
    if request.session['type'] != "admin":
        return redirect('/')
    request.session['studid'] = id
    return render(request,'Admin/addconcesssion.html')

def addconcession_submit(request):
    Amount = request.POST['textfield']
    Sem = request.POST['select']

    if Concession.objects.filter(semester=Sem,STUDENT_id=request.session['studid']).exists():
        return HttpResponse("<script>alert('Concession already Exist for this semester');window.location='/viewstudent'</script>")

    obj=Concession()
    obj.semester=Sem
    obj.concession_fee=Amount
    obj.STUDENT_id=request.session['studid']
    obj.save()
    sid = request.session['studid']
    print(sid)
    return HttpResponse("<script>alert('Concession Added Successfully');window.location='/viewconcession/"+sid+"'</script>")

@login_required(login_url='/')
@never_cache
def home(request):
    if request.session['type'] != "admin":
        return redirect('/')
    # Dashboard counts
    staff_count = staff.objects.count()
    student_count = student.objects.count()
    course_count = course.objects.count()
    feedback_count = Feedback.objects.count()

    context = {
        'staff_count': staff_count,
        'student_count': student_count,
        'course_count': course_count,
        'feedback_count': feedback_count,
    }
    return render(request,'Admin/home.html', context)


def removestaff(request,id):
    staff.objects.get(id=id).delete()
    return HttpResponse("<script>alert('Staff Removed Successfully');window.location='/viewstaff'</script>")

def removecourse(request,id):
    course.objects.get(id=id).delete()
    return HttpResponse("<script>alert('Course Removed Successfully');window.location='/viewcourse'</script>")

def removecoursefee(request,id)  :
    Fee.objects.filter(id=id).delete()
    return HttpResponse("<script>alert('Course Fee Removed Successfully');window.location='/viewfee'</script>")

def removecoursefeealert(request,id):
    Alert.objects.filter(id=id).delete()
    return HttpResponse("<script>alert('Fee Alert Removed Successfully');window.location='/viewfeealert'</script>")

# def removeconsession(request,id):
#     Concession.objects.get(id=id).delete()
#     return HttpResponse("<script>alert('Concession Removed Successfully');window.location='/viewconcession'</script>")


def removestudent(request,id):
    student.objects.get(id=id).delete()
    return HttpResponse("<script>alert('Student Removed Successfully');window.location='/viewstudent'</script>")

def rejectstudent(request,id):
    request.session['studid'] = id
    student.objects.get(id=id).delete()
    return HttpResponse("<script>alert('Student Rejected Successfully');window.location='/viewstudentverify'</script>")


def approvestudent(request,id):
    request.session['id'] = id
    student.objects.filter(id=id).update(status="Active")
    return HttpResponse("<script>alert('Student Approved Successfully');window.location='/viewstudent'</script>")


def closeaccount(request,id):
    request.session['id'] = id
    student.objects.filter(id=id).update(status="Inactive")
    return HttpResponse("<script>alert('Account Closed Successfully');window.location='/viewstudent'</script>")


def feeajax(request,sem,cid):
    data = Fee.objects.filter(semester=sem,COURSE=cid)
    return render(request, 'Admin/feeajax.html',{'data2':data})

#Staff Module
@login_required(login_url='/')
@never_cache
def StaffAddfee(request):
    if request.session['type'] != "staff":
        return redirect('/')
    data =course.objects.all()
    data2 = range(2023,int(datetime.now().year) + 2)
    return render(request,'Staff/StaffAddfee.html',{'data':data,'data2':data2})
def StaffAddFee_submit(request):
    print(request.POST,"ok")
    Semester =request.POST['select']
    Batch =request.POST['select2']
    Feee =request.POST['textfield']
    fee = request.POST.getlist('fee')
    title =request.POST.getlist('title')

    if Fee.objects.filter(semester=Semester,batch=Batch,COURSE_id=request.POST['select3']).exists():
        return HttpResponse("<script>alert('Fee Already Exist');window.location='/StaffViewFee'</script>")
    obj=Fee()
    obj.semester=Semester
    obj.batch=Batch
    obj.fee=Feee
    obj.COURSE_id = request.POST['select3']
    obj.save()

    for i in range(0,len(fee)):
        obj2 = Feetype()
        obj2.title = title[i]
        obj2.fee = fee[i]
        obj2.FEE_id = obj.id
        obj2.save()

    return HttpResponse("<script>alert('Fee Added Successfully');window.location='/StaffViewFee'</script>")


@login_required(login_url='/')
@never_cache
def editfeestaff(request,id):
    if request.session['type'] != "staff":
        return redirect('/')
    data=Fee.objects.get(id=id)
    data2= course.objects.all()
    data3 = Feetype.objects.filter(FEE=id)
    request.session['id'] = id
    return render(request,'Staff/StaffEditfee.html',{'data':data,'data2':data2,'data3':data3})
def editfeestaff_submit(request):

    Feee =request.POST['textfield']

    Fee.objects.filter(id= request.session['id']).update(fee=Feee)

    fee = request.POST.getlist('fee')
    title = request.POST.getlist('title')
    id = request.POST.getlist('id')

    for i in range(0, len(fee)):
        try:
            if fee[i] != "" and title[i] != "":
                if str(id[i]) == "0":
                    obj2 = Feetype()
                    obj2.title = title[i]
                    obj2.fee = fee[i]
                    obj2.FEE_id = request.session['id']
                    obj2.save()
                else:
                    obj2 = Feetype.objects.get(id=id[i])
                    obj2.title = title[i]
                    obj2.fee = fee[i]
                    obj2.save()
            if id[i] == "" and title[i] != "":
                obj2 = Feetype()
                obj2.title = title[i]
                obj2.fee = fee[i]
                obj2.FEE_id = request.session['id']
                obj2.save()
        except Exception as e:
            print(e,"Error")
            obj2 = Feetype()
            obj2.title = title[i]
            obj2.fee = fee[i]
            obj2.FEE_id = request.session['id']
            obj2.save()

    return HttpResponse("<script>alert('Fee Edited Successfully');window.location='/StaffViewFee'</script>")


def removecoursefeestaff(request,id)  :
    feedetails = Fee.objects.filter(id=request.session['id'])
    total = int(feedetails[0].fee) - int(Feetype.objects.get(id=id).fee)
    feedetails.update(fee=total)
    Feetype.objects.get(id=id).delete()
    return HttpResponse(
        f"<script>alert('Fee Removed Successfully');window.location='/editfeestaff/{request.session['id']}'</script>")


@login_required(login_url='/')
@never_cache
def StaffEditFee(request):
    if request.session['type'] != "staff":
        return redirect('/')
    return render(request,'Staff/StaffEditfee.html')

@login_required(login_url='/')
@never_cache
def searchstudent(request):
    if request.session['type'] != "staff":
        return redirect('/')
    return render(request,'staff/SearchStudent.html')

def searchedstudent(request):
    Email = request.POST['textfield']
    data = student.objects.filter(email=Email)
    return render(request, 'Staff/searchedstudent.html', {'data': data})




@login_required(login_url='/')
@never_cache
def StaffHome(request):
    if request.session['type'] != "staff":
        return redirect('/')
    # Fee-related counts for staff dashboard
    pending_payments = payments.objects.filter(status__icontains='pending').count()
    verified_payments = payments.objects.filter(status__icontains='verified').count()
    # Active alerts: alerts with todate >= today
    today = datetime.today()
    active_alerts = Alert.objects.filter(todate__gte=today).count()
    total_students = student.objects.count()

    context = {
        'pending_payments': pending_payments,
        'verified_payments': verified_payments,
        'active_alerts': active_alerts,
        'total_students': total_students,
    }
    return render(request,'staff/StaffHome.html', context)

@login_required(login_url='/')
@never_cache
def staff_change_password(request):
    if request.session['type'] != "staff":
        return redirect('/')
    return render(request,'staff/staff_change_password.html')
def staff_change_password_submit(request):
    Current_Password =request.POST['textfield']
    New_Password =request.POST['textfield2']
    Confirm_Password =request.POST['textfield3']
    if str(request.session['p']) == Current_Password:
        User.objects.filter(id=request.user.id).update(password=make_password(New_Password))
        return HttpResponse("<script>alert('Password Changed Successfully');window.location='/StaffHome'</script>")
    return HttpResponse("<script>alert('Current password does not match');window.location='/staff_change_password'</script>")

def delete_fee(request,id):
    Fee.objects.get(id=id).delete()
    return redirect('/StaffViewFee')

@login_required(login_url='/')
@never_cache
def StaffViewFee(request):
    if request.session['type'] != "staff":
        return redirect('/')
    data = Fee.objects.all()
    # Render admin view template but point actions to staff endpoints
    return render(request,'Staff/StaffViewFee.html',{'data':data,'add_url':'/StaffAddfee','edit_url_prefix':'/editfeestaff','remove_url_prefix':'/removecoursefeestaff','is_staff':True})

# @login_required(login_url='/')
# @never_cache
# def viewpayementverfication(request):
#     if request.session['type'] != "staff":
#         return redirect('/')
#     data = payments.objects.all()
#     return render(request,'staff/viewpayementverification.html',{'data':data})

@login_required(login_url='/')
@never_cache
def viewverifiedpayment(request):
    if request.session['type'] != "staff":
        return redirect('/')
    data = payments.objects.filter(status="success")
    return render(request,'staff/viewverifiedpayment.html',{'data':data})

@login_required(login_url='/')
@never_cache
def viewpendingrequeststaff(request):
    if request.session['type'] != "staff":
        return redirect('/')
    data = payments.objects.filter(status="pending")
    return render(request,'staff/viewpendingrequeststaff.html',{'data':data})

@login_required(login_url='/')
@never_cache
def viewadminfeealert(request):
    if request.session['type'] != "staff":
        return redirect('/')
    data = Alert.objects.filter(TYPE="admin")
    return render(request,'Staff/viewadminfeealert.html',{'data':data})


@login_required(login_url='/')
@never_cache
def addfeealertstaff(request):
    if request.session['type'] != "staff":
        return redirect('/')
    data = course.objects.all()
    data2 =Fee.objects.all()
    # Render the admin AddFeeAlert template but post to staff submit endpoint
    return render(request, 'Staff/AddFeeAlertStaff.html', {'data': data, 'data2': data2, 'form_action': '/addfeealertstaff_submit', 'is_staff': True})


def addfeealertstaff_submit(request):
    Course =request.POST['select']
    Semester =request.POST['select2']
    Note =request.POST['textfield']
    Fine_amount =request.POST['textfield2']
    Todate =request.POST['datefield']
    Fine_date =request.POST['datefield2']
    Fees =request.POST['select3']
    obj=Alert()
    obj.FEE_id=Fees
    obj.todate=Todate
    obj.note=Note
    obj.finedate=Fine_date
    obj.fineamount=Fine_amount
    obj.TYPE = "staff"
    obj.fromdate = datetime.now().date()
    obj.save()

    fee_obj = Fee.objects.get(id=Fees)

    studdata = student.objects.filter(batch=fee_obj.batch, COURSE=fee_obj.COURSE_id, semester=fee_obj.semester)
    for i in studdata:
        obj2 = Alertsub()
        obj2.STUDENT_id = i.id
        obj2.ALERT_id = obj.id
        obj2.save()
    return HttpResponse("<script>alert('Fee Alert Added Successfully');window.location='/viewstafffeealert'</script>")

@login_required(login_url='/')
@never_cache
def viewstafffeealert(request):
    if request.session['type'] != "staff":
        return redirect('/')
    data = Alert.objects.filter(TYPE="staff")
    # Render admin view template but point actions to staff endpoints
    return render(request, 'Staff/viewstafffeealert.html', {'data': data, 'add_url': '/addfeealertstaff', 'edit_url_prefix': '/editstafffeealert', 'remove_url_prefix': '/removestafffeealert', 'is_staff': True})

@login_required(login_url='/')
@never_cache
def editstafffeealert(request,id):
    if request.session['type'] != "staff":
        return redirect('/')
    data = Alert.objects.get(id=id)
    data2 = course.objects.all()
    request.session['id'] = id
    return render(request, 'Staff/EditStaffFeeAlert.html',{'data':data,'data2':data2})

def editstafffeealert_submit(request):
    # Course =request.POST['select']
    # Semester =request.POST['select2']
    Note =request.POST['textfield']
    Fine_amount =request.POST['textfield2']
    Todate =request.POST['datefield']
    Fine_date =request.POST['datefield2']
    Alert.objects.filter(id=request.session['id']).update(note=Note,todate=Todate,finedate=Fine_date,fineamount=Fine_amount)

    return HttpResponse("<script>alert('Fee Alert Edited Successfully');window.location='/viewstafffeealert'</script>")

def removestafffeealert(request,id):
    Alert.objects.filter(id=id).delete()
    return HttpResponse("<script>alert('Fee Alert Removed Successfully');window.location='/viewstafffeealert'</script>")



def forgotpassword(request):
    return render(request,"forgotpassword.html")
def forgotpasswordbuttonclick(request):
    email = request.POST['textfield']
    if User.objects.filter(username=email).exists():
        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart

        # ✅ Gmail credentials (use App Password, not real password)
        sender_email = "mail.edupay@gmail.com"
        receiver_email = email  # change to actual recipient
        app_password = "tybc lbmz grvl daqh"  # App Password from Google
        pwd = str(random.randint(1100,9999))  # Example password to send
        request.session['otp'] = pwd
        request.session['email'] = email

        # Setup SMTP
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(sender_email, app_password)

        # Create the email
        msg = MIMEMultipart("alternative")
        msg["From"] = sender_email
        msg["To"] = receiver_email
        msg["Subject"] = "Your OTP"

        # Plain text (backup)
        # text = f"""
        # Hello,

        # Your password for Smart Donation Website is: {pwd}

        # Please keep it safe and do not share it with anyone.
        # """

        # HTML (attractive)
        html = f"""
        <html>
          <body style="font-family: Arial, sans-serif; color: #333;">
            <h2 style="color:#2c7be5;">Edupay</h2>
            <p>Hello,</p>
            <p>Your OTP is:</p>
            <p style="padding:10px; background:#f4f4f4; 
                      border:1px solid #ddd; 
                      display:inline-block;
                      font-size:18px;
                      font-weight:bold;
                      color:#2c7be5;">
              {pwd}
            </p>
            <p>Please keep it safe and do not share it with anyone.</p>
            <hr>
            <small style="color:gray;">This is an automated email from Edupay.</small>
          </body>
        </html>
        """

        # Attach both versions
        # msg.attach(MIMEText(text, "plain"))
        msg.attach(MIMEText(html, "html"))

        # Send email
        server.send_message(msg)
        print("✅ Email sent successfully!")

        # Close connection
        server.quit()
        return HttpResponse("<script>window.location='/otp'</script>")
    else:
        return HttpResponse("<script>alert('Email not found');window.location='/forgotpassword'</script>")


def otp(request):
    return render(request,"otp.html")
def otpbuttonclick(request):
    otp  = request.POST["textfield"]
    if otp == str(request.session['otp']):
        return HttpResponse("<script>window.location='/forgotpswdpswed'</script>")
    else:
        return HttpResponse("<script>alert('incorrect otp');window.location='/otp'</script>")

def forgotpswdpswed(request):
    return render(request,"forgotpswdpswed.html")
def forgotpswdpswedbuttonclick(request):
    np = request.POST["password"]
    User.objects.filter(username=request.session['email']).update(password=make_password(np))
    return HttpResponse("<script>alert('password has been changed');window.location='/' </script>")

@login_required(login_url='/')
@never_cache
def viewcomplaints(request):
    if request.session.get('type') != "staff":
        return redirect('/')

    # We use prefetch_related if you want to optimize,
    # but in the template we can call i.complaintsub_set.all
    data = Complaints.objects.all().order_by('-date')
    return render(request, 'Staff/viewcomplaints.html', {'data': data})


@login_required(login_url='/')
@never_cache
def updatecomplaint(request,id):
    if request.session['type'] != "staff":
        return redirect('/')
    data = Complaints.objects.get(id=id)
    request.session['id'] = id
    images = complaintsub.objects.filter(COMPLAINTS=id)
    return render(request, 'Staff/updatecomplaint.html',{'data':data,'images':images})

def updatecomplaint_submit(request):

    status =request.POST['status']
    reply =request.POST['staff_reply']
    Complaints.objects.filter(id=request.session['id']).update(status=status,reply=reply)

    return HttpResponse("<script>alert('Fee Alert Edited Successfully');window.location='/viewcomplaints'</script>")


##User Studsent Module
# def login_submit(request):
#     Username =request.POST['textfield']
#     Password =request.POST['textfield2']
#     data = authenticate(username=Username,password=Password)
#     if data is not None:
#         request.session['p'] = Password
#         login(request,data)
#         if data.is_superuser:
#             return HttpResponse(
#                 "<script>alert('Login Success');window.location='/home'</script>")
#
#         if data.groups.filter(name="staff").exists():
#             return HttpResponse(
#                 "<script>alert('Login Success');window.location='/StaffHome'</script>")
#
#     else:
#         return HttpResponse("Failed")


def Ulogin(request):
    mobile = request.POST['mobile']
    data = student.objects.filter(phone=mobile)
    print(data)
    if data.exists():
        if data[0].status == "Active":
            print('hello')
            return JsonResponse({"status":"ok"})
        return JsonResponse({"status":"Please wait for Approval "})
    else:
        return JsonResponse({"status":"Invalid Mobile number"})


def Uregister(request):
    name= request.POST['name']
    adm_no= request.POST['adm_no']
    email= request.POST['email']
    mobile= request.POST['mobile']
    batch= request.POST['batch']
    sem= request.POST['sem']
    course= request.POST['course']

    obj1 = User()
    obj1.username = email
    # obj1.password = make_password(Phone)
    obj1.save()
    obj1.groups.add(Group.objects.get(name="student"))

    obj = student()
    obj.name = name
    obj.email = email
    obj.phone = mobile
    obj.batch = batch
    obj.semester = sem
    obj.COURSE_id = course
    obj.LOGIN = obj1
    obj.adm_no = adm_no
    obj.status = "pending"
    obj.save()
    return JsonResponse({"status":"ok"})


def Uchangepassword(request):
    return JsonResponse({"status":"User Change password"})

def Uforgotpassword_email(request):
    return JsonResponse({"status":"User forgotpassword email"})

def Uforgotpassword_otp(request):
    return JsonResponse({"status":"User forgotpassword otp"})

def Uforgotpassword_change(request):
    return JsonResponse({"status":"User forgotpassword chaange"})


def Uviewprofile(request):
    data = student.objects.filter(phone=request.POST['mobile'])
    ar = []
    for i in data:
        # Get absolute URL for the photo if it exists
        photo_url = request.build_absolute_uri(i.photo.url) if i.photo else "no_image"

        ar.append({
            'id': i.id,
            'Email': i.email,
            'Phone': i.phone,
            'Name': i.name,
            'Batch': i.batch,
            'Sem': i.semester,
            'photo': photo_url,  # New field
            'Department': i.COURSE.department,
            'Course': i.COURSE.course,
        })
    return JsonResponse({"status": "User viewprofile", "data": ar})

def UFeestructure(request):
    mobile=request.POST['mobile']
    data2 = student.objects.get(phone=mobile)
    print(data2.batch)
    data3 = payments.objects.filter(STUDENT__phone=mobile)
    data4 = Fee.objects.filter(COURSE=data2.COURSE,batch=data2.batch).order_by('semester')
    totalamountpaid=0
    for i in data3:
        totalamountpaid+=int(i.totalamount)

    totalamount = 0
    for i in data4:
        totalamount+= int(i.fee)
    pendingamount= totalamount-totalamountpaid

    ar = []
    for i in data4:
        data2 = Feetype.objects.filter(FEE=i.id)
        newar = []
        for j in data2:
            newar.append({
                'title':j.title,
                'fee':j.fee
            })
        ar.append({
            'id': i.id,
            'department':i.COURSE.department,
            'course':i.COURSE.course,
            'details':i.COURSE.details,
            'sem':i.semester,
            'fee':i.fee,
            'batch':i.batch,
            'more':newar
        })
    return JsonResponse({"status":"User Feestructure","data":ar,"totalamountpaid":totalamountpaid,"totalamount":totalamount,"pendingamount":pendingamount})

def Uviewalert(request):
    mobile = request.POST['mobile']
    studata = student.objects.get(phone=mobile)
    data = Alert.objects.filter(FEE__COURSE=studata.COURSE_id,FEE__semester=studata.semester,FEE__batch=studata.batch)
    ar = []
    for i in data:
        try:
            ar.append({
                'id': i.id,
                'depatment': i.FEE.COURSE.department,
                'course': i.FEE.COURSE.course,
                'details': i.FEE.COURSE.details,
                'sem': i.FEE.semester,
                'fee': i.FEE.fee,
                'batch': i.FEE.batch,
                'fromdate': i.fromdate,
                'todate': i.todate,
                'Note': i.note,
                'Fine Date': i.finedate,
                'Fine Amount': i.fineamount,
                'staffname': i.STAFF.name,
                'staffemail': i.STAFF.email,
                'staffpost': i.STAFF.post,
                'TYPE': i.TYPE,

            })
        except:
            ar.append({
                'id': i.id,
                'depatment': i.FEE.COURSE.department,
                'course': i.FEE.COURSE.course,
                'details': i.FEE.COURSE.details,
                'sem': i.FEE.semester,
                'fee': i.FEE.fee,
                'batch': i.FEE.batch,
                'From Date': i.fromdate,
                'todate': i.todate,
                'Note': i.note,
                'Fine Date': i.finedate,
                'Fine Amount': i.fineamount,
                'staffname': 'Admin',
                'staffemail': '',
                'staffpost': '',
                'TYPE': i.TYPE,

            })
    return JsonResponse({"status":"User viewalert","data":ar})

def Uview_payments(request):
    mobile = request.POST['mobile']

    data = payments.objects.filter(STUDENT__phone=mobile)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'depatment': i.FEE.COURSE.department,
            'course': i.FEE.COURSE.course,
            'details': i.FEE.COURSE.details,
            'sem': i.FEE.semester,
            'fee': i.FEE.fee,
            'batch': i.FEE.batch,
            'sname': i.STUDENT.name,
            'semail': i.STUDENT.email,
            'sphone': i.STUDENT.phone,
            'sstatus': i.STUDENT.status,
            'sadm_no': i.STUDENT.adm_no,
            'Date': i.date,
            'Status': i.status,
            'Amount': i.totalamount,
            'fineamount': i.fineamount,
        })
    return JsonResponse({"status":"User View payments","data":ar})

def Umissedalert(request):
    mobile = request.POST['mobile']
    studentdata = student.objects.get(phone=mobile)
    data = Alert.objects.filter(FEE__COURSE=studentdata.COURSE_id,FEE__batch=studentdata.batch,FEE__semester=studentdata.semester)
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'depatment': i.FEE.COURSE.department,
            'course': i.FEE.COURSE.course,
            'details': i.FEE.COURSE.details,
            'sem': i.FEE.semester,
            'fee': i.FEE.fee,
            'batch': i.FEE.batch,
            'From Date': i.fromdate,
            'todate': i.todate,
            'Note': i.note,
            'Fine Date': i.finedate,
            'Fine Amount': i.fineamount,
            'staffname': 'Admin',
            'staffemail': '',
            'staffpost': '',
            'Type': i.TYPE,

        })
    return JsonResponse({"status":"User Missed Alert","data":ar})


# views.py

from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.core.files.storage import default_storage
import os
from .models import Complaints   # Your complaint model


def Uraise_complaint(request):
        title = request.POST.get('title', '')
        category = request.POST.get('category', '')
        description = request.POST.get('description', '')
        mobile = request.POST.get('mobile', '')

        # ✅ Handle multiple image uploads
        images = request.FILES.getlist('images')  # Gets all uploaded images

        # ✅ Create complaint record
        complaint = Complaints.objects.create(
            date=datetime.now().date(),
            title=title,
            category=category,
            description=description,
            STUDENT=student.objects.get(phone=mobile),
            status='Pending'
        )

        # ✅ Save all uploaded images
        image_paths = []
        for image in images:
            # Save image to media folder
            file_path = default_storage.save(
                f'complaints/{complaint.id}/{image.name}',
                image
            )
            image_paths.append(file_path)

            # Save image reference (if you have ComplaintImage model)
            complaintsub.objects.create(COMPLAINTS=complaint, image=file_path)

        return JsonResponse({
            'status': 'success',
            'message': 'Complaint raised successfully',
            'complaint_id': complaint.id,
            'images_uploaded': len(images)
        })


def Uview_complaints(request):
    mobile = request.POST.get('mobile', '')
    if not mobile:
        return JsonResponse({'status': 'error', 'message': 'mobile required', 'data': []})
    try:
        student_obj = student.objects.get(phone=mobile)
    except student.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'student not found', 'data': []})

    complaints = Complaints.objects.filter(STUDENT=student_obj).order_by('-date')
    result = []
    for c in complaints:
        result.append({
            'id': c.id,
            'title': c.title,
            'date': c.date.strftime('%Y-%m-%d') if c.date else '',
            'status': c.status,
            'category': c.category,
            'description': c.description,
            # include staff reply if available
            'staff_reply': c.reply if hasattr(c, 'reply') else '',
        })
    return JsonResponse({'status': 'ok', 'data': result})


def Sview_complaint_status(request):
    cid = request.POST.get('cid', '').strip()
    if not cid:
        return JsonResponse({'status': 'error', 'message': 'cid required'}, status=400)
    try:
        c = Complaints.objects.get(id=cid)
    except Complaints.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'complaint not found'}, status=404)

    # collect attachments (if any)
    subs = complaintsub.objects.filter(COMPLAINTS=c)
    attachments = [s.image for s in subs]
    attachment_val = attachments[0] if attachments else ''

    status_text = (c.status or '').lower()
    steps = ['Submitted', 'Viewed by Staff', 'In Progress', 'Resolved']
    # determine how many steps are done based on status
    done_count = 0
    if 'pending' in status_text:
        done_count = 1
    elif 'view' in status_text or 'open' in status_text:
        done_count = 2
    elif 'progress' in status_text or 'in progress' in status_text:
        done_count = 3
    elif 'resolve' in status_text or 'complete' in status_text or 'closed' in status_text:
        done_count = 4

    timeline = []
    for idx, step in enumerate(steps):
        done = 1 if idx < done_count else 0
        date_val = c.date.strftime('%Y-%m-%d') if (done == 1 and idx == 0) else ''
        timeline.append({'step': step, 'done': str(done), 'date': date_val})

    return JsonResponse({
        'complaint_id': c.id,
        'title': c.title,
        'date': c.date.strftime('%Y-%m-%d') if c.date else '',
        'status': c.status,
        'description': c.description,
        'category': c.category,
        'staff_reply': c.reply or '',
        'attachment': attachment_val,
        'timeline': timeline,
    })



def Uhome(request):
    return JsonResponse({"status":"User Home"})

def paid(request):
    amount = request.POST['amt']

    return JsonResponse({"status": "ok"})

def payment_success(request):
    import datetime
    amount= request.POST['amt']
    mobile= request.POST['mobile']
    data = student.objects.get(phone=mobile)
    obj=payments()
    obj.FEE_id = request.POST['fid']
    obj.STUDENT=data
    obj.date = datetime.datetime.now().date()
    obj.totalamount=amount
    obj.fineamount=0
    obj.status="success"
    obj.save()

    return JsonResponse({"status": "ok"})


import google.generativeai as genai
genai.configure(api_key="AIzaSyCnfvL1ShgTo7lKAiMNzlAJrR8T69DMd5E")  # Replace with your actual key

def user_sendchat(request):
    FROM_id=request.POST['from_id']
    data = student.objects.get(phone=FROM_id)



    msg=request.POST['message']
    import datetime

    # from  datetime import datetime
    c=chatbot()
    c.STUDENT_id=data.id
    c.message=msg
    c.type='user'
    c.date=datetime.datetime.now()
    c.save()

    message = msg



    coursedata = course.objects.all()
    feedata = Fee.objects.all()
    paymentsdata = payments.objects.all()
    concessiondata = Concession.objects.all()
    complaintsdata = Complaints.objects.all()

    studentdata = student.objects.filter()



    me = student.objects.get(phone=FROM_id)

    # Convert data to text
    courses_text = "\n".join([str(c.course) for c in coursedata])
    fees_text = "\n".join([f"{f.COURSE.course} - {f.semester} -{f.fee} - " for f in feedata])
    payments_text = "\n".join([f"{p.STUDENT.name} paid {p.totalamount}" for p in paymentsdata])
    concession_text = "\n".join([f"{c.semester} - {c.concession_fee}" for c in concessiondata])
    complaints_text = "\n".join([f"{c.title} - {c.status}" for c in complaintsdata])
    studenttext= "\n".join([f"{s.name} - {s.COURSE.course} - {s.batch} - {s.semester} - {s.adm_no}" for s in studentdata])
    me= "\n".join([f"{s.name} - {s.COURSE.course} - {s.batch} - {s.semester} - {s.adm_no}" for s in studentdata])
    print(me)

    # Initialize Gemini
    model = genai.GenerativeModel('models/gemini-2.5-flash-lite')
    #
    # # Create prompt
    # prompt = f"""
    # You are a helpful EduPay assistant.
    # Answer the user's question using the provided system data.
    #
    # Courses:
    # {courses_text}
    #
    # Fees:
    # {fees_text}
    #
    # Payments:
    # {payments_text}
    #
    # Concessions:
    # {concession_text}
    #
    # Complaints:
    # {complaints_text}
    #
    # User:
    # {studenttext}
    #
    # My Details:
    # {me}
    #
    # User Question:
    # {message}
    # 1. Get ONLY the current student's data
    # (data is already the student object from your line: data = student.objects.get(phone=FROM_id))
    me_text = f"Name: {data.name}, Course: {data.COURSE.course}, Batch: {data.batch}, Semester: {data.semester}, Adm No: {data.adm_no}"

    # 2. Filter other data to be relevant to THIS student (optional but recommended for accuracy)
    my_payments = payments.objects.filter(STUDENT=data)
    my_concessions = Concession.objects.filter(STUDENT=data)
    my_complaints = Complaints.objects.filter(STUDENT=data)

    # 3. Convert to text
    courses_text = "\n".join([str(c.course) for c in coursedata])
    fees_text = "\n".join([f"{f.COURSE.course} - Sem {f.semester}: ${f.fee}" for f in feedata])
    payments_text = "\n".join([f"Paid {p.totalamount} on {p.date}" for p in my_payments])
    concession_text = "\n".join([f"Sem {c.semester}: {c.concession_fee} discount" for c in my_concessions])
    complaints_text = "\n".join([f"{c.title} (Status: {c.status})" for c in my_complaints])

    # Updated Prompt Construction
    prompt = f"""
        You are a helpful EduPay assistant. 
        Current Student Profile (THIS IS THE USER YOU ARE TALKING TO):
        {me_text}

        Available Courses:
        {courses_text}

        General Fee Structure:
        {fees_text}

        User's Specific Payment History:
        {payments_text}

        User's Concessions:
        {concession_text}

        User's Support Tickets:
        {complaints_text}

        User Question: {message}


    Guidelines:
    - Be friendly and professional
    - Use bullet points if needed
    - Keep answer short and clear
    """

    # Generate response
    response = model.generate_content(
        prompt,
        generation_config={
            "temperature": 0.5,
            "max_output_tokens": 300
        }
    )

    print("Gemini:", response.text)

    c = chatbot()
    c.STUDENT_id= data.id
    c.message = response.text
    c.type = "AI"
    c.date = datetime.datetime.now()
    c.save()

    return JsonResponse({'status':"ok"})


def user_viewchat(request):
    from_id=request.POST['from_id']
    data = student.objects.get(phone=from_id)


    l=[]
    data=chatbot.objects.filter(STUDENT__phone=data.phone).order_by('id')
    for res in data:
        l.append({'id':res.id,'from':res.STUDENT.id,'msg':res.message,'date':res.date,'type':res.type})



    return JsonResponse({'status':"ok",'data':l})


def getcourses(request):
    data = course.objects.filter()
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'depatment': i.department,
            'course': i.course,
            'details': i.details,
        })

    print(ar,"ok")
    return JsonResponse({'status':"ok",'courses':ar})


# def getstudentdata(request):
#
#         mobile = request.POST.get('mobile', '').strip()
#
#         if not mobile:
#             return JsonResponse({
#                 'status': 'error',
#                 'message': 'Mobile number is required'
#             }, status=400)
#
#         # Fetch student from database
#         studentss = student.objects.get(phone=mobile)
#
#         # Get all fees
#         fees = Fee.objects.filter(COURSE=studentss.COURSE,semester=studentss.semester)
#         print(fees,"EFEFE")
#         # Calculate fee information
#         try:
#             total_fee = fees[0].fee
#         except:
#             total_fee = 0
#
#         # Get completed payments
#         paymentss = payments.objects.filter(
#             STUDENT=studentss,
#             status='success'
#         )
#         paid_amount = paymentss.aggregate(total=Sum('totalamount'))['total'] or 0
#
#         pending_fee = float(total_fee) - float(paid_amount)
#
#         # Get due date (from earliest pending fee)
#         pending_fees = paymentss.filter(status__in=['pending', 'Overdue']).order_by('due_date')
#         due_date = 'N/A'
#         if pending_fees.exists():
#             due_date = Alert.objects.filter(id=fees[0].id).first().todate.strftime('%d %b %Y')
#         cid = Complaints.objects.filter(STUDENT__phone=mobile)
#         if cid.count() > 0:
#             cid = cid.order_by('-id')[0].id
#         else:
#             cid = 0
#         response_data = {
#             'status': 'ok',
#             'data': {
#                 'cid': cid,
#                 'name': studentss.name,
#                 'adm_no': studentss.semester,
#                 'email': studentss.email,
#                 'phone': studentss.phone,
#                 'course': studentss.COURSE.course if studentss.COURSE else 'N/A',
#                 'sem': str(studentss.semester),
#                 'batch': str(studentss.batch),
#                 'department': studentss.COURSE.department if studentss.COURSE else 'N/A',
#                 'section': studentss.semester or 'N/A',
#
#                 # Fee information
#                 'total_fee': str(int(total_fee)),
#                 'paid_amount': str(int(paid_amount)),
#                 'pending_fee': str(int(pending_fee)),
#                 'due_date': due_date,
#
#                 # Status information
#                 'status': studentss.status,
#                 'admission_date': studentss.adm_no,
#             }
#         }
#
#         print(response_data)
#
#         return JsonResponse(response_data)

from django.db.models import Sum
from datetime import date


def getstudentdata(request):
    mobile = request.POST.get('mobile', '').strip()

    if not mobile:
        return JsonResponse({'status': 'error', 'message': 'Mobile number is required'}, status=400)

    # Fetch student
    studentss = student.objects.get(phone=mobile)

    # Get all fees
    fees = Fee.objects.filter(COURSE=studentss.COURSE, semester=studentss.semester,batch=studentss.batch)

    try:
        total_fee = fees[0].fee
    except:
        total_fee = 0

    # ✅ NEW: Concession Logic (Aggressive match)
    discount = 0
    con_obj = Concession.objects.filter(STUDENT=studentss)
    for c in con_obj:
        if str(c.semester).replace(" ", "").lower() == str(studentss.semester).replace(" ", "").lower():
            discount = c.concession_fee
            break

    # Get completed payments
    paymentss = payments.objects.filter(STUDENT=studentss, status='success')
    paid_amount = paymentss.aggregate(total=Sum('totalamount'))['total'] or 0

    # ✅ NEW: Fine Logic (Checking if today is past finedate)
    fine_to_add = 0
    due_date = 'N/A'
    alert_obj = Alert.objects.filter(FEE=fees[0]).first() if fees.exists() else None

    if alert_obj:
        due_date = alert_obj.todate.strftime('%d %b %Y')
        # If today (March 3) is >= finedate (e.g. Feb 1), apply fine
        if date.today() >= alert_obj.finedate:
            fine_to_add = alert_obj.fineamount

    # ✅ CORRECT FORMULA: (Total - Discount + Fine) - Paid
    pending_fee = (float(total_fee) - float(discount) + float(fine_to_add)) - float(paid_amount)

    cid = Complaints.objects.filter(STUDENT__phone=mobile)
    cid = cid.order_by('-id')[0].id if cid.exists() else 0
    # Check if the photo exists, otherwise provide a default or None
    if studentss.photo:
        photo_url = request.build_absolute_uri(studentss.photo.url)
    else:
        # Option A: Send a placeholder image URL
        # photo_url = request.build_absolute_uri('/static/images/default_profile.png')

        # Option B: Send an empty string or None
        photo_url = ""

    # RESTORED ORIGINAL RESPONSE STRUCTURE
    response_data = {
        'status': 'ok',
        'data': {
            'cid': cid,
            'name': studentss.name,
            'photo': photo_url,
            'adm_no': studentss.adm_no,  # Restored original
            'email': studentss.email,
            'phone': studentss.phone,
            'course': studentss.COURSE.course if studentss.COURSE else 'N/A',
            'sem': str(studentss.semester),  # Restored original
            'batch': str(studentss.batch),
            'department': studentss.COURSE.department if studentss.COURSE else 'N/A',
            'section': studentss.semester or 'N/A',

            'total_fee': str(int(total_fee)),
            'paid_amount': str(int(paid_amount)),
            'pending_fee': str(int(max(0, pending_fee))),  # Included Concession & Fine
            'due_date': due_date,

            'status': studentss.status,
            'admission_date': studentss.adm_no,
        }
    }
    return JsonResponse(response_data)

def ViewFeedbacks(request):
    ob=Feedback.objects.all()
    mdata=[]
    for i in ob:
        data={
            'id':i.id,
            'feedback':i.feedback,
            'date':i.date,
            'by_student':i.STUDENT.name,
        }
        mdata.append(data)
    return JsonResponse({'status':'ok','data':mdata})

def SendFeedback(request):
    lid = request.POST['lid']
    data = student.objects.get(phone=lid)
    ob=Feedback()
    ob.STUDENT=data
    ob.feedback = request.POST['feedback']
    ob.date = datetime.today()
    ob.save()

    return JsonResponse({'status':'ok'})



def UpdateProfile(request):
    lid=request.POST['lid']
    ob=student.objects.get(phone=lid)
    ob.email = request.POST['email']
    ob.name = request.POST['name']
    ob.batch = request.POST['batch']
    ob.semester = request.POST['semester']
    if 'photo' in request.FILES:
        ob.photo=request.FILES['photo']
    ob.save()
    return JsonResponse({'status':'ok'})




import json
import traceback  # Added for debugging
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import google.generativeai as genai
from .models import course, Fee, Feetype



@csrf_exempt
def public_chatbot(request):
    if request.method == 'POST':
        try:
            # Check if request body is empty
            if not request.body:
                return JsonResponse({'error': 'Empty request body'}, status=400)

            data = json.loads(request.body)
            user_message = data.get('message', '').lower().strip()

            db_context = ""

            # 1. Database Lookup Logic
            if any(word in user_message for word in ["fee", "cost", "pay", "amount"]):
                fee_list = Fee.objects.all()
                fee_data = []
                for f in fee_list:
                    feetypes = Feetype.objects.filter(FEE=f)
                    breakdown = ", ".join([f"{ft.title}: {ft.fee}" for ft in feetypes])
                    # Note: f.COURSE.course assumes COURSE is the field name on Fee model
                    fee_data.append(
                        f"Course: {f.COURSE.course if f.COURSE else 'N/A'}, Sem: {f.semester}, Total: {f.fee}, Breakdown: ({breakdown})")
                db_context = "Current Fee Structure: " + " | ".join(fee_data)

            elif any(word in user_message for word in ["course", "department", "study"]):
                course_list = course.objects.all()
                course_data = [f"{c.course} in {c.department} department ({c.details})" for c in course_list]
                db_context = "Available Courses: " + " | ".join(course_data)

            # 2. Gemini Interaction
            # Check model name: usually gemini-1.5-flash
            model = genai.GenerativeModel(
                model_name='gemini-2.5-flash',
                system_instruction="You are a helpful campus assistant. Use the provided database context to answer. If information isn't in context, answer generally or ask for details."
            )

            prompt = f"Context from database: {db_context}\n\nUser Question: {user_message}"

            response = model.generate_content(prompt)

            # Check if response actually returned text
            if response and response.text:
                return JsonResponse({'reply': response.text}, status=200)
            else:
                return JsonResponse({'reply': "I'm sorry, I couldn't process that request."}, status=200)

        except Exception as e:
            # THIS IS THE IMPORTANT PART FOR DEBUGGING:
            # It prints the full error stack trace to your terminal
            print("--- CHATBOT ERROR ---")
            print(traceback.format_exc())
            return JsonResponse({'error': str(e), 'details': 'Check console for traceback'}, status=500)

    return JsonResponse({'error': 'POST only'}, status=405)

