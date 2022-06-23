<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="DashboardPW2022._default" %>



<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/docs/4.0/assets/img/favicons/favicon.ico">

    <title>Accedi | Parcheggi</title>

    <link rel="icon" type="image/x-icon" href="https://barriersigns.com.au/wp-content/uploads/2019/05/Guide_G7-6-min.png">

    <!-- Bootstrap core CSS -->
    <link href="Content/bootstrap.min.css" rel="stylesheet" />

    <!-- Custom styles for this template -->
    <link href="signin.css" rel="stylesheet">
  </head>
   
  <body class="text-center">
      <div class="container">
        <div id="alertObj" runat="server" class="alert alert-primary alert-dismissible fade show" role="alert" hidden="hidden">
            <svg class="bi flex-shrink-0 me-2" id="alertSvg" width="24" height="24" role="img" runat="server" aria-label="Info:">
               <use id="alertImg" runat="server" xlink:href="#info-fill"/>
            </svg>
            <asp:Label ID="lblConsole" class="" runat="server" Text="Pronto"></asp:Label>
            <button type="button" class="btn-close " data-bs-dismiss="alert" style="position: absolute; top: 0; right: 0; z-index: 2; padding: 1.25rem 1rem;" aria-label="Close"></button>
         </div>
        <form class="form-signin" runat="server">
          <img class="mb-4 mt-5" src="https://barriersigns.com.au/wp-content/uploads/2019/05/Guide_G7-6-min.png" alt="" width="72" height="72">
          <h1 class="h3 mb-3 font-weight-normal">Accedi</h1>
          <label for="inputEmail" class="sr-only">Username</label>
          <%--<input type="email" runat="server" id="txbUser" class="form-control" placeholder="Username" required autofocus> --%>  
          <asp:TextBox ID="txbUser"  class="form-control" runat="server" placeholder="Username" ></asp:TextBox>
          
          <label for="inputPassword" class="sr-only">Password</label>
          
            
            <%--<input type="password"  runat="server"  id="txbPass" class="form-control" placeholder="Password" required>--%>  
            <asp:TextBox ID="txbPass" type="password"   class="form-control" runat="server" placeholder="Password" ></asp:TextBox>

          <asp:Button ID="btnSubmit" class="btn btn-lg btn-primary btn-block mt-3" runat="server" Text="Accedi" OnClick="btnSubmit_Click" />
          <p class="mt-5 mb-3 text-muted">&copy; 2022</p>
        </form>
      </div>
  </body>
</html>
