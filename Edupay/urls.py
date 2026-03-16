"""Edupay URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path

from myapp import views

urlpatterns = [
    path('admin/', admin.site.urls),
    #index
    # path('', views.index),
    ####
    path('addcourse', views.addcourse),
    path('addcourse_submit', views.addcourse_submit),
    path('addfee', views.addfee),
    path('addfeealert', views.addfeealert),
    path('addstaff', views.addstaff),
    path('addstudent', views.addstudent),
    path('changepassword', views.changepassword),
    path('editcourse/<id>', views.editcourse),
    path('editfee/<id>', views.editfee),
    path('removefee/<id>', views.removefee),
    path('editfeealert/<id>', views.editfeealert),
    path('editstaff/<id>', views.editstaff),
    path('editstudent/<id>', views.editstudent),
    path('forgotpassword', views.forgotpassword),
    path('', views.loginn),
    path('payment', views.payment, name='payment'),
    path('generate-payment-report', views.generate_payment_report, name='generate_payment_report'),
    path('get-filter-options', views.get_filter_options, name='get_filter_options'),
    path('get-payment-summary', views.get_payment_summary, name='get_payment_summary'),
    path('rejectreason', views.rejectreason),
    path('viewcourse', views.viewcourse),
    path('viewfee', views.viewfee),
    path('viewfeealert', views.viewfeealert),
    path('viewfeedback', views.viewfeedback),
    path('viewstaff', views.viewstaff),
    path('viewstudent', views.viewstudent),
    path('viewstudentverify', views.viewstudentverify),
    path('addfee', views.addfee),
    path('editfee', views.editfee),
    path('addfee_submit', views.addfee_submit),
    path('addfeealert_submit', views.addfeealert_submit),
    path('addstaff_submit', views.addstaff_submit),
    path('addstudent_submit', views.addstudent_submit),
    path('changepassword_submit', views.changepassword_submit),
    path('editfee_submit', views.editfee_submit),
    path('editcourse_submit', views.editcourse_submit),
    path('editfeealert_submit', views.editfeealert_submit),
    path('editstaff_submit', views.editstaff_submit),
    path('editstudent_submit', views.editstudent_submit),
    path('login_submit', views.login_submit),
    path('rejectreason_submit', views.rejectreason_submit),
    path('viewconcession/<id>', views.viewconcession),
    path('addconcession/<id>', views.addconcession),
    path('addconcession_submit', views.addconcession_submit),
    path('home', views.home),
    path('removestaff/<id>', views.removestaff),
    path('removecourse/<id>', views.removecourse),
    path('removecoursefee/<id>', views.removecoursefee),
    path('removecoursefeealert/<id>', views.removecoursefeealert),
    path('removestudent/<id>', views.removestudent),
    path('removeconcession/<id>', views.removeconcession),
    path('rejectstudent/<id>', views.rejectstudent),
    path('approvestudent/<id>', views.approvestudent),
    path('closeaccount/<id>', views.closeaccount),
    path('feeajax/<sem>/<cid>', views.feeajax),
    path('semchange', views.semchange),
    path('changesem_submit', views.changesem_submit),

#Staff Module
     path('searchstudent', views.searchstudent),
     path('searchedstudent', views.searchedstudent),
     path('StaffHome', views.StaffHome),
     path('delete_fee/<id>', views.delete_fee),
     path('StaffAddfee', views.StaffAddfee),
     path('editfeestaff/<id>', views.editfeestaff),
     path('editfeestaff_submit', views.editfeestaff_submit),
     path('removecoursefeestaff/<id>', views.removecoursefeestaff),
     path('StaffViewFee', views.StaffViewFee),
     path('StaffEditFee', views.StaffEditFee),
     # path('viewpayementverfication', views.viewpayementverfication),
     path('viewverifiedpayment', views.viewverifiedpayment),
     path('viewpendingrequeststaff', views.viewpendingrequeststaff),
     path('viewconcession', views.viewconcession),
     path('StaffAddFee_submit', views.StaffAddFee_submit),
     path('viewadminfeealert', views.viewadminfeealert),
     path('staff_change_password', views.staff_change_password),
     path('staff_change_password_submit', views.staff_change_password_submit),
     path('addfeealertstaff', views.addfeealertstaff),
     path('addfeealertstaff_submit', views.addfeealertstaff_submit),
     path('viewstafffeealert', views.viewstafffeealert),
     path('editstafffeealert/<id>', views.editstafffeealert),
     path('editstafffeealert_submit', views.editstafffeealert_submit),
     path('updatecomplaint_submit', views.updatecomplaint_submit),
     path('removestafffeealert/<id>', views.removestafffeealert),
    path('viewcomplaints', views.viewcomplaints),
    path('updatecomplaint/<id>', views.updatecomplaint),

    path('logout', views.logouts),

    path('forgotpassword',views.forgotpassword),
    path('forgotpasswordbuttonclick',views.forgotpasswordbuttonclick),
    path('otp',views.otp),
    path('otpbuttonclick',views.otpbuttonclick),
    path('forgotpswdpswed',views.forgotpswdpswed),
    path('forgotpswdpswedbuttonclick',views.forgotpswdpswedbuttonclick),

    #User Module
    path('Ulogin', views.Ulogin),
    path('Uforgotpassword_email',views.Uforgotpassword_email),
    path('Uforgotpassword_otp',views.Uforgotpassword_otp),
    path('Uforgotpassword_change',views.Uforgotpassword_change),
    path('Uviewprofile',views.Uviewprofile),
    path('UFeestructure',views.UFeestructure),
    path('Uviewalert',views.Uviewalert),
    path('Uview_payments',views.Uview_payments),
    path('Umissedalert',views.Umissedalert),
    path('Uchangepassword',views.Uchangepassword),
    path('Uraise_complaint',views.Uraise_complaint),
    path('Uhome',views.Uhome),
    path('Uregister',views.Uregister),
    path('paid',views.paid),
    path('payment_success',views.payment_success),
    path('user_sendchat',views.user_sendchat),
    path('user_viewchat',views.user_viewchat),
    path('getcourses',views.getcourses),
    path('getstudentdata',views.getstudentdata),
    path('Uview_complaints', views.Uview_complaints),
    path('Sview_complaint_status', views.Sview_complaint_status),
    path('public_chatbot/', views.public_chatbot),
    path('ViewFeedbacks/', views.ViewFeedbacks),
    path('SendFeedback/', views.SendFeedback),
    path('UpdateProfile', views.UpdateProfile),


]
urlpatterns += static(settings.MEDIA_URL,document_root=settings.MEDIA_ROOT)