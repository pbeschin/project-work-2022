<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="DashboardPW2022.WebForm1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
   <head runat="server">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
       <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, shrink-to-fit=no">
      <title>Dashboard | Parcheggi</title>
      <!--CSS-->
      <link href="Content/bootstrap.min.css" rel="stylesheet" />
      <!--SCRIPT JS-->
      <script src="Scripts/jquery-3.6.0.min.js"></script>
      <!--BOOTSTRAP-->
      <script src="Scripts/bootstrap.bundle.min.js"></script>
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/cdbootstrap/css/bootstrap.min.css" />
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/cdbootstrap/css/cdb.min.css" />
      <script src="https://cdn.jsdelivr.net/npm/cdbootstrap/js/cdb.min.js"></script>
      <script src="https://cdn.jsdelivr.net/npm/cdbootstrap/js/bootstrap.min.js"></script>
      <script src="https://kit.fontawesome.com/9d1d9a82d2.js" crossorigin="anonymous"></script>
      <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

      <link rel="icon" type="image/x-icon" href="https://barriersigns.com.au/wp-content/uploads/2019/05/Guide_G7-6-min.png">
   </head>
   <body>
      <form id="form1" runat="server">
         <div class="container-fluid" style="padding: 0;">
         <nav class="navbar navbar-dark bg-primary fixed">
            <div class="container-fluid">
               <a class="navbar-brand" href="#">SP ltd. - gestione parcheggi</a>
               <button class="navbar-toggler" type="button" data-bs-toggle="offcanvas" data-bs-target="#offcanvasNavbar" aria-controls="offcanvasNavbar">
              <%-- <span class="navbar-toggler-icon"> --%>
                   <%--<img src="Img/hamburger-white.jpg"  width="20" /> --%>
                   <span class="align-top">&#9776;</span>

               <%--</span>--%>
               </button>
               <div class="offcanvas offcanvas-end bg-primary" tabindex="-1" id="offcanvasNavbar" aria-labelledby="offcanvasNavbarLabel">
                  <div class="offcanvas-header">
                     <h5 class="offcanvas-title text-white" id="offcanvasNavbarLabel">Menù</h5>
                     <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
                  </div>
                  <div class="offcanvas-body d-flex justify-content-between flex-column">
                     <div class="form-group">
                         <h3  class="text-white">Contattaci: </h3>
                        <label for="exampleFormControlInput1"  class="text-white">Email: </label>

                         <asp:TextBox ID="txbOggetto"  class="form-control"  placeholder="Oggetto" runat="server"></asp:TextBox>
                        <label class="text-white" for="exampleFormControlTextarea1">Il tuo messaggio: </label>
                        <textarea runat="server" class="form-control" id="txbMessaggio" rows="10" placeholder="Messaggio"></textarea>
                      </div>
                      <asp:Button ID="btnInviaMail" class="btn btn-light" runat="server" Text="Invia" OnClick="btnInviaMail_Click" />
                     <div>
                        <hr />
                        <div class="text-white">Frequenza di aggiornamento:</div>
                        <div class="dropdown align-bottom">
                           <asp:DropDownList class="btn btn-primary dropdown-toggle" ID="ddlAggiornamento" AutoPostBack="True"  runat="server" OnSelectedIndexChanged="ddlAggiornamento_SelectedIndexChanged">
                              <asp:ListItem Value="60000" >1 minuto</asp:ListItem>
                              <asp:ListItem Value="120000">2 minuti</asp:ListItem>
                              <asp:ListItem Selected="True" Value="300000">5 minuti</asp:ListItem>
                           </asp:DropDownList>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </nav>
         <div class="container">
         <svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
            <symbol id="check-circle-fill" fill="currentColor" viewBox="0 0 16 16">
               <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>
            </symbol>
            <symbol id="info-fill" fill="currentColor" viewBox="0 0 16 16">
               <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"/>
            </symbol>
            <symbol id="exclamation-triangle-fill" fill="currentColor" viewBox="0 0 16 16">
               <path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
            </symbol>
         </svg>
         <div id="alertObj" runat="server" class="alert alert-primary alert-dismissible fade show" role="alert" hidden="hidden">
            <svg class="bi flex-shrink-0 me-2" id="alertSvg" width="24" height="24" role="img" runat="server" aria-label="Info:">
               <use id="alertImg" runat="server" xlink:href="#info-fill"/>
            </svg>
            <asp:Label ID="lblConsole" class="" runat="server" Text="Pronto"></asp:Label>
            <button type="button" class="btn-close " data-bs-dismiss="alert" style="position: absolute; top: 0; right: 0; z-index: 2; padding: 1.25rem 1rem;" aria-label="Close"></button>
         </div>
         <asp:Button ID="btnAggiorna" class="btn btn-primary mt-2 float-right" runat="server" Text="Aggiorna valori" OnClick="btnAggiorna_Click" />
         <div class="row  mt-2">
            <!-- Earnings (Monthly) Card Example -->
            <div class="col-xl-3 col-md-6 mb-4">
               <div class="card border-left-primary shadow h-100 py-2">
                  <div class="card-body">
                     <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                           <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                              Tariffa attuale: 
                           </div>
                           <div class="h5 mb-0 font-weight-bold text-gray-800">€ <asp:Label ID="lblTariffa" class="h5 mb-0 font-weight-bold text-gray-800" runat="server" Text="0,50"></asp:Label></div>
                           
                        </div>
                        <div class="col-auto">
                           <i class="fas fa-dollar-sign fa-2x text-gray-300"></i>
                           
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            <!-- Earnings (Monthly) Card Example -->
            <div class="col-xl-3 col-md-6 mb-4">
               <div class="card border-left-success shadow h-100 py-2">
                  <div class="card-body">
                     <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                           <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                              Affluenza settimanale: 
                           </div>
                          
                            <asp:Label ID="lblAffluenzaSettimanale" class="h5 mb-0 font-weight-bold text-gray-800" runat="server" Text="0"></asp:Label>
                        </div>
                        <div class="col-auto">
                           

                            <img src="https://img.icons8.com/ios-glyphs/24/000000/taxi.png" style="width="16px"; height="30px";" class="fas fa-2x text-gray-300"/>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            <!-- Earnings (Monthly) Card Example -->
            <div class="col-xl-3 col-md-6 mb-4">
               <div class="card border-left-info shadow h-100 py-2">
                  <div class="card-body">
                     <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                           <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Affluenza attuale:
                           </div>
                           <div class="row no-gutters align-items-center">
                              <div class="col-auto">
                                 <div class="h5 mb-0 mr-3 font-weight-bold text-gray-800">
                                    <asp:Label ID="lblAffluenza" class="h5 mb-0 mr-3 font-weight-bold text-gray-800" runat="server" Text="-"></asp:Label>
                                    / 100
                                 </div>
                              </div>
                              <div class="col">
                                 <div class="progress progress-sm mr-2">
                                    <div id="prgAffluenza" runat="server" class="progress-bar bg-info" role="progressbar" style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                 </div>
                              </div>
                           </div>
                        </div>
                        <div class="col-auto">
                           <i class="fas fa-clipboard-list fa-2x text-gray-300"></i>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            <!-- Pending Requests Card Example -->
            <div class="col-xl-3 col-md-6 mb-4">
               <div class="card border-left-warning shadow h-100 py-2">
                  <div class="card-body">
                     <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                           <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                              Permanenza media: 
                               
                           </div>
                           <asp:Label ID="lblTempoMedio" class="h5 mb-0 font-weight-bold text-gray-800" runat="server" Text="00:00:00"></asp:Label>
                        </div>
                        <div class="col-auto">
                           <%-- <i class="fas fa-comments fa-2x text-gray-300"></i> --%>
                            <img src="Img/icons8-clessidra-90.png"  style="width="16px"; height="30px";" class="fas fa-2x text-gray-300"/>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </div>
         <%--<div class="row" style="margin-top: 1%;">
            <div class="col-sm-4">
              <div class="card border-primary">
                <div class="card-body">
                  <h5 class="card-title"><asp:Label ID="lblPostiOccupati" class="card-title" runat="server" Text="0"></asp:Label>/100</h5>
                  <p class="card-text">Posti occupati</p>
                    <asp:Button ID="btnAggiornaAffluenza" class="btn btn-primary" runat="server" Text="Aggiorna affluenza" OnClick="btnAggiornaAffluenza_Click" />
                </div>
              </div>
            </div>
            
            <div class="col-sm-4">
              <div class="card border-primary">
                <div class="card-body">
                  <h5 class="card-title"><asp:Label ID="lblTariffa" class="card-title" runat="server" Text="€ 0,50"></asp:Label></h5>
                  <p class="card-text">Tariffa attuale</p>
                  <a href="#" class="btn btn-primary">Reset</a>
                </div>
              </div>
            </div>
            
             <div class="col-sm-4">
              <div class="card border-primary">
                <div class="card-body">
                  <h5 class="card-title"><asp:Label ID="lblTempoPermanenza" class="card-title" runat="server" Text="2:54:30"></asp:Label></h5>
                  <p class="card-text">Permanenza media </p>
                  <a href="#" class="btn btn-primary">Reset</a>
                </div>
              </div>--%>
         <asp:ScriptManager ID="ScriptManager1" runat="server">
         </asp:ScriptManager>
         <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
               <asp:Label ID="lblTime" runat="server" />
               <asp:Timer ID="Timer1" runat="server" OnTick="Timer1_Tick" Interval="300000"></asp:Timer>
            </ContentTemplate>
         </asp:UpdatePanel>
         <%-- /div> --%>
         <%-- </div> --%>
         <div class="row">
             <div class="col-xl-7 col-lg-7 mb-4">
                <div class="card shadow mb-4 h-100">
                   <!-- Card Header - Dropdown -->
                   <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                      <h6 class="m-0 font-weight-bold text-primary">Affluenza settimanale</h6>
                      <div class="dropdown no-arrow">
                       
                      </div>
                   </div>
                   <!-- Card Body -->
                   <div class="card-body">
                      <div class="chart-area h-100">
                         <div class="chartjs-size-monitor">
                            <div class="chartjs-size-monitor-expand">
                               <div class=""></div>
                            </div>
                            <div class="chartjs-size-monitor-shrink">
                               <div class=""></div>
                            </div>
                         </div>
                         <%--<canvas id="myAreaChart" style="display: block; width: 472px; height: 320px;" width="472" height="320" class="chartjs-render-monitor"></canvas>--%>
                         <div style="height: 90%">
                             <script>
                                 <% var serializer = new System.Web.Script.Serialization.JavaScriptSerializer(); %>
                                 var Attuale = <%= serializer.Serialize(arrSettimanaAttuale) %>;
                                 var Precedente = <%= serializer.Serialize(arrSettimanaPrecedente) %>;
                             </script>
                            <canvas id="mainChart" runat="server"></canvas>
                         </div>
                         <script>
                             const labels = [
                                 'Lunedì',
                                 'Martedì',
                                 'Mercoledì',
                                 'Giovedì',
                                 'Venerdì',
                                 'Sabato',
                                 'Domenica',
                             ];

                             const data = {
                                 labels: labels,
                                 datasets: [{
                                     label: 'Precedente',
                                     // 118, 67, 230
                                     backgroundColor: 'rgb(158, 197, 254)',
                                     borderColor: 'rgb(158, 197, 254)',
                                     data: Precedente,
                                 },
                                 {
                                     label: 'Attuale',
                                     // 118, 67, 230
                                     backgroundColor: 'rgb(13, 110, 253)',
                                     borderColor: 'rgb(13, 110, 253)',
                                     data: Attuale,
                                 }
                                 ]
                             };

                             const config = {
                                 type: 'line',
                                 data: data,
                                 options: {
                                     responsive: true,
                                     maintainAspectRatio: false
                                 }
                             };

                         </script>
                         <script>
                             const myChart = new Chart(
                                 document.getElementById('mainChart'),
                                 config
                             );
                         </script>
                      </div>
                   </div>
                </div>
             </div>
             <div class="col-xl-5 col-lg-5">
                            <div class="card shadow mb-4">
                                <!-- Card Header - Dropdown -->
                                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">Pannello di controllo</h6>
                                </div>
                                <!-- Card Body -->
                                <div class="card-body">
                                    Tipo parcheggio:
                                    <div class="row mt-1">
                                        <div class="col-4">
                                             <asp:Button ID="btnOrdinario" class="btn btn-success w-100" runat="server" Text="Ordinario" OnClick="btnOrdinario_Click" UseSubmitBehavior="False" 
                                                 data-bs-toggle="tooltip" 
                                                 data-bs-placement="bottom" 
                                                 title="Calcola la tariffa in base alla somma complessiva delle soste in ORE del giorno della settimana scorsa, rispetto alla media" />           
                                        </div>
                                        <div class="col-4">
                                            <asp:Button ID="btnAltaRotazione" class="btn btn-light w-100" runat="server" Text="Ad alta rotazione" OnClick="btnAltaRotazione_Click" UseSubmitBehavior="False"  
                                                data-bs-toggle="tooltip" 
                                                data-bs-placement="bottom" 
                                                title="Calcola la tariffa in base alla somma complessiva degli INGRESSI e USCITE del giorno della settimana scorsa, rispetto alla media" />
                                        </div>
                                        <div class="col-4">
                                            <asp:Button ID="btnTariffaForzata" class="btn btn-light w-100" runat="server" Text="Tariffa fissa" OnClick="btnTariffaForzata_Click" UseSubmitBehavior="False"  
                                                data-bs-toggle="tooltip" 
                                                data-bs-placement="bottom" 
                                                title="Forza la tariffa inserita dall'utente" />
                                        </div>
                                    </div>
                                    
                                    <div id="divTariffaFissa" runat="server" class="row mt-3 align-items-center" style="margin-left: 2%; width:95%;">
                                        
                                    Tariffa oraria odierno:
                                      <asp:TextBox ID="txbTariffa" class="col-4 form-control"  placeholder="" runat="server"></asp:TextBox>
                                       
                                        <asp:Button ID="btnAggiornaTariffa" class="btn btn-primary col-4 mt-3" runat="server" Text="Aggiorna" OnClick="btnAggiornaTariffa_Click" />
                                         
                                    </div>
                                  


                                </div>

                                         </div>
                 <div class="card shadow mb-4">
                                <!-- Card Header - Dropdown -->
                                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">Lista transazioni</h6>
                                </div>
                                <!-- Card Body -->
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-4">
                                            Da: <asp:TextBox ID="txbDataDa" Text="" textmode="Date" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="col-4">
                                            A: <asp:TextBox ID="txbDataA" Text=""  textmode="Date"  runat="server"></asp:TextBox>
                                        </div>
                                        <div class="col-4">
                                            <asp:Button ID="btnFiltra" class="btn btn-primary" runat="server" Text="Filtra" OnClick="btnFiltra_Click" />
                                        </div>
                                    </div>
                                    
           
                                    <div style="height:200px;overflow-x: hidden; overflow-y: scroll; background:#fff;">
                                        <asp:GridView ID="grdTransazioni" style="width: auto; font-size: 5px; LINE-HEIGHT:20px;" class="table table-hover table-striped table-responsive table-sm" runat="server"></asp:GridView>  
                                    </div>
                    
                                    
                                </div>
             </div>
                                </div>
             
         </div>
          <div>
                <div class="card shadow mb-4">
                   <!-- Card Header - Dropdown -->
                   <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                      <h6 class="m-0 font-weight-bold text-primary">Situazione attuale</h6>
                      <div class="dropdown no-arrow">
     
                      </div>
                   </div>
                   <!-- Card Body -->
                   <div class="card-body">
                      <div class="chart-area">
  
                        <div style="  height:400px;overflow-x: hidden; overflow-y: scroll;;background:#fff;">
                            <div class="row">
                                <div class="col-6">
                                    <h4 class="text-center m-0 font-weight-bold text-primary">Piano terra</h4>
                                   <asp:GridView ID="GridView1" class="thead" cssClass="table" runat="server" OnRowDataBound="GridView1_RowDataBound" HeaderStyle-Wrap="True"></asp:GridView>
                                </div>
                                <div class="col-6">
                                    <h4 class="text-center m-0 font-weight-bold text-primary">Primo piano</h4>
                                    <asp:GridView ID="GridView2" cssClass="table" runat="server" OnRowDataBound="GridView1_RowDataBound"></asp:GridView>
                                </div>
                                
                            </div>
                            
                        
                   </div>
                </div>
             </div>
            </div>
             </div>
          <div>
 
         </div>
      </form>
   </body>
   <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.js"></script>
</html>