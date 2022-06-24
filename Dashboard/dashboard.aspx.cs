using Microsoft.Azure.Devices;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Reflection;
using Newtonsoft.Json.Linq;
using System.Text;
using System.Net.Mail;
//using System.Text.Json;

namespace DashboardPW2022
{

    public partial class WebForm1 : System.Web.UI.Page
    {
        string API_URL = "https://pw2022-apinode.azurewebsites.net/";
        string API_URL_FILTRI = "https://pw2022-apinode.azurewebsites.net/lista/transazioni?";
        List<Posto> piano1 = new List<Posto>();
        List<Posto> piano2 = new List<Posto>();
        List<Transazioni> transazioni = new List<Transazioni>();
        int affluenza = 0;
        string tempoMedio = "";
        int affluenzaSettimanale = 0;
        protected int[] arrSettimanaAttuale = new int[] { 0, 0, 0, 0, 0, 0, 0 };
        protected int[] arrSettimanaPrecedente = new int[] { 0, 0, 0, 0, 0, 0, 0 };

 

        //public List<int> arrSettimanaAttuale = new List<int> { 0, 0, 0, 0, 0, 0, 0 };
        protected void Page_Load(object sender, EventArgs e)
        {
            UpdateAffluenza();
            UpdateTariffe();
            UpdateTempoMedio();
            UpdateGraph();
            ReadPiano(0);
            ReadPiano(1);
            ReadTransazioni();
            txbTariffa.Attributes["placeholder"] = lblTariffa.Text;
            if (GetModalitaAttuale() == 2)
            {
                divTariffaFissa.Visible = true;
            } else
            {
                divTariffaFissa.Visible = false;
            }
            /* TO-DO
            if (GetModalitaAttuale() != 2)
            {
                //txbTariffa.Enabled = false;
                //btnAggiornaTariffa.Enabled = false;
                txbTariffa.Attributes.Add("", "disabled"); ;
                btnAggiorna.Attributes.Add("", "disabled"); ;
            } else
            {
                txbTariffa.Enabled = true;
                btnAggiornaTariffa.Enabled = true;
            }
            */
            //txbDataA.Attributes["value"] = DateTime.Today.ToString("dd/mm/yyyy");
            //txbDataA.Text = DateTime.Today.ToString("dd/mm/yyyy");
            //txbDataDa.Text = DateTime.Now.AddDays(-7).ToString();
            //txbDataA.Text = DateTime.Now.ToString();
            // TO-DO
        }

        private void UpdateTariffe()
        {
            try
            {
                string myURL = API_URL + "tariffe";
                //string reqCity = txbCitta.Text;
                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();

                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore
                };

                Tariffe t = JsonConvert.DeserializeObject<Tariffe>(responseFromServer, settings);

                reader.Close();
                dataStream.Close();
                response.Close();



                if (GetModalitaAttuale() == 0) // tariffa ordinaria
                {
                    try
                    {
                        this.lblTariffa.Text = t.costo_orario.ToString();
                    }
                    catch (Exception ex)
                    {
                        this.lblConsole.Text = "Errore nel reperimento dei dati: " + ex.Message;
                        alertObj.Attributes.Remove("hidden");
                        alertObj.Attributes["class"] = "alert alert-danger";
                        alertImg.Attributes["aria-label"] = "Danger";
                        alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                    }
                    
                }
                else if (GetModalitaAttuale() == 1) // alta rotazione
                {
                    try
                    {
                        this.lblTariffa.Text = t.costo_orario_rotazione.ToString();
                    }
                    catch (Exception ex)
                    {
                        this.lblConsole.Text = "Errore nel reperimento dei dati: " + ex.Message;
                        alertObj.Attributes.Remove("hidden");
                        alertObj.Attributes["class"] = "alert alert-danger";
                        alertImg.Attributes["aria-label"] = "Danger";
                        alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                    }
                }
                else if (GetModalitaAttuale() == 2) // forzata
                {
                    try
                    {
                        this.lblTariffa.Text = t.costo_forzato.ToString();
                    }
                    catch (Exception ex)
                    {
                        this.lblConsole.Text = "Errore nel reperimento dei dati: " + ex.Message;
                        alertObj.Attributes.Remove("hidden");
                        alertObj.Attributes["class"] = "alert alert-danger";
                        alertImg.Attributes["aria-label"] = "Danger";
                        alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                    }
                }
                else if (GetModalitaAttuale() == -1)
                {
                    this.lblConsole.Text = "Errore nel reperimento della modalita di calcolo tariffa ";
                    alertObj.Attributes.Remove("hidden");
                    alertObj.Attributes["class"] = "alert alert-danger";
                    alertImg.Attributes["aria-label"] = "Danger";
                    alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                }
                    
            }
            catch (NullReferenceException ex)
            {
                this.lblConsole.Text = "Errore nel reperimento dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";

                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        private int GetModalitaAttuale()
        {
            int modalita = 0;
            try
            {
                string myURL = API_URL + "modalitaTariffa";
                //string reqCity = txbCitta.Text;
                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();

                modalita = Convert.ToInt32(responseFromServer);

                if (modalita == 0)
                {
                    btnAltaRotazione.Attributes["class"] = "btn btn-light w-100";
                    btnOrdinario.Attributes["class"] = "btn btn-success w-100";
                    btnTariffaForzata.Attributes["class"] = "btn btn-light w-100";
                }
                else if (modalita == 1)
                {
                    btnOrdinario.Attributes["class"] = "btn btn-light w-100";
                    btnAltaRotazione.Attributes["class"] = "btn btn-success w-100";
                    btnTariffaForzata.Attributes["class"] = "btn btn-light w-100";
                }
                else if (modalita == 2)
                {
                    btnOrdinario.Attributes["class"] = "btn btn-light w-100";
                    btnAltaRotazione.Attributes["class"] = "btn btn-light w-100";
                    btnTariffaForzata.Attributes["class"] = "btn btn-success w-100";
                }


                reader.Close();
                dataStream.Close();
                response.Close();

                return modalita;

            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                return -1;
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                return -1;

                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        private void ReadTransazioni()
        {
            try
            {
                string myURL = API_URL + "lista/transazioni"; // ip pc di Pietro
                                                              //string myURL = "https://pw2022-apinode.azurewebsites.net/transazioni/lista";
                                                              //string reqCity = txbCitta.Text;

                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();


                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore
                };

                transazioni = JsonConvert.DeserializeObject<List<Transazioni>>(responseFromServer, settings);

                DataTable dt = ConvertiListaTransazioniInDataTable(transazioni);

                
                grdTransazioni.DataSource = dt;
                
                grdTransazioni.DataBind();

                reader.Close();
                dataStream.Close();
                response.Close();
            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        // TO-DO: implementazione metodo che determina la tariffa giornaliera (possibiità di impostare tariffa base o utilizzare l'ultima tariffa)
        protected decimal SetPrice()
        {
            return 0;
        }

        protected void ShowPiano0(object sender, EventArgs e)
        {
            ReadPiano(0);

        }

        protected void Home(object sender, EventArgs e)
        {
            try
            {
                GridView1.DataSource = null;
                GridView1.DataBind();
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella tabella dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }

        }

        protected void ShowPiano1(object sender, EventArgs e)
        {
            ReadPiano(1);

        }
        protected void ReadPiano(int piano)
        {
            try
            {
                string pianoString = "";

                if (piano == 0)
                {
                    pianoString = "terra";
                }
                else if (piano == 1)
                {
                    pianoString = "primo";
                }

                //string APIKEY = "8de3e8c1d8c893c04f412c2e5bb517ea";
                string myURL = API_URL + "lista/stato/" + pianoString; // ip pc di Pietro
                //string reqCity = txbCitta.Text;

                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();

                piano1 = JsonConvert.DeserializeObject<List<Posto>>(responseFromServer);
                piano2 = JsonConvert.DeserializeObject<List<Posto>>(responseFromServer);

                if (piano == 0)
                {
                    GridView1.DataSource = ConvertiListaPostoInDataTable(piano1);
                    GridView1.DataBind();
                    GridView1.HeaderRow.Visible = false;

                }
                else if (piano == 1)
                {
                    GridView2.DataSource = ConvertiListaPostoInDataTable(piano2);
                    GridView2.DataBind();
                    GridView2.HeaderRow.Visible = false;
                }




                UpdateAffluenza();
                //this.lblPostiOccupati.Text = affluenza.ToString();

                reader.Close();
                dataStream.Close();
                response.Close();

            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        private DataTable ConvertiListaPostoInDataTable(List<Posto> piano)
        {
            DataTable dataTable = new DataTable(typeof(Posto).Name);
            //Get all the properties
            PropertyInfo[] Props = typeof(Posto).GetProperties(BindingFlags.Public | BindingFlags.Instance);
            foreach (PropertyInfo prop in Props)
            {
                //Setting column names as Property names
                dataTable.Columns.Add(prop.Name);
            }
            foreach (Posto item in piano)
            {
                var values = new object[Props.Length];
                for (int i = 0; i < Props.Length; i++)
                {
                    //inserting property values to datatable rows
                    values[i] = Props[i].GetValue(item, null);
                }
                dataTable.Rows.Add(values);
            }
            //put a breakpoint here and check datatable
            return dataTable;
        }

        private DataTable ConvertiListaTransazioniInDataTable(List<Transazioni> piano)
        {
            DataTable dataTable = new DataTable(typeof(Transazioni).Name);
            Transazioni p;
            //Get all the properties
            PropertyInfo[] Props = typeof(Transazioni).GetProperties(BindingFlags.Public | BindingFlags.Instance);
            foreach (PropertyInfo prop in Props)
            {
                //Setting column names as Property names
                dataTable.Columns.Add(prop.Name);
            }
            foreach (Transazioni item in piano)
            {
                var values = new object[Props.Length];
                for (int i = 0; i < Props.Length; i++)
                {
                    //inserting property values to datatable rows
                    values[i] = Props[i].GetValue(item, null);
                }
                dataTable.Rows.Add(values);
            }
            //put a breakpoint here and check datatable
            return dataTable;
        }

        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            try
            {

                if (!(e.Row.RowIndex == -1))
                {
                    if (Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "presenza")) == false)
                    {
                        //e.Row.BackColor = System.Drawing.Color.Cyan;
                        e.Row.Attributes["class"] = "table-success";
                    }
                    else if (Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "presenza")) == true)
                    {
                        e.Row.Attributes["class"] = "table-danger";

                    }
                }
            }
            catch (Exception exc)
            {
                this.lblConsole.Text = "Errore nel databind della tabella: " + exc.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }


        }

        protected void Timer1_Tick(object sender, EventArgs e)
        {
            Response.Redirect(Request.RawUrl);
        }

        protected void ddlAggiornamento_SelectedIndexChanged(object sender, EventArgs e)
        {
            Timer1.Interval = Convert.ToInt32(ddlAggiornamento.SelectedValue);
            this.lblConsole.Text = "Frequenza di aggiornamento cambiata a " + Timer1.Interval / 60000 + " minuti";
            alertObj.Attributes.Remove("hidden");
            alertObj.Attributes["class"] = "alert alert-success";
            alertImg.Attributes["aria-label"] = "Success";
            alertImg.Attributes["href"] = "#check-circle-fill";
        }

        protected void btnAggiornaAffluenza_Click(object sender, EventArgs e)
        {
            UpdateAffluenza();
        }


        private void UpdateAffluenza()
        {
            try
            {
                string myURL = API_URL + "countPosti";
                //string reqCity = txbCitta.Text;
                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();
                affluenza = Convert.ToInt32(responseFromServer);

                this.lblAffluenza.Text = affluenza.ToString();
                this.prgAffluenza.Attributes["aria-valuenow"] = affluenza.ToString();
                this.prgAffluenza.Attributes["style"] = "width: " + affluenza.ToString() + "%";


            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";

                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }

        }

        private void UpdateTempoMedio()
        {
            try
            {
                string myURL = API_URL + "tempoMedio";
                //string reqCity = txbCitta.Text;
                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();
                tempoMedio = (responseFromServer);


                this.lblTempoMedio.Text = tempoMedio.Substring(12, 8);

            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }

        }

        protected void btnAggiorna_Click(object sender, EventArgs e)
        {
            try
            {
                UpdateTempoMedio();
                UpdateAffluenza();
                this.lblConsole.Text = "Valori aggiornati correttamente";
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-success";
                alertImg.Attributes["aria-label"] = "Success";
                alertImg.Attributes["href"] = "#check-circle-fill";
            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }

        }

        protected void btnAggiornaTariffa_Click(object sender, EventArgs e)
        {
            try
            {
                // PUt
                string myURL = API_URL + "tariffe"; // 

                // Create a request using a URL that can receive a post.
                WebRequest request = WebRequest.Create(myURL);
                // Set the Method property of the request to POST.
                request.Method = "PUT";

                // Create POST data and convert it to a byte array.
                string postData = "{ \"costo_forzato\": " + txbTariffa.Text + "}";
           
                byte[] byteArray = Encoding.UTF8.GetBytes(postData);

                // Set the ContentType property of the WebRequest.
                request.ContentType = "application/json";
                // Set the ContentLength property of the WebRequest.
                request.ContentLength = byteArray.Length;

                // Get the request stream.
                Stream dataStream = request.GetRequestStream();
                // Write the data to the request stream.
                dataStream.Write(byteArray, 0, byteArray.Length);
                // Close the Stream object.
                dataStream.Close();

                // Get the response.
                WebResponse response = request.GetResponse();
                // Display the status.
                Console.WriteLine(((HttpWebResponse)response).StatusDescription);

                // Get the stream containing content returned by the server.
                // The using block ensures the stream is automatically closed.
                using (dataStream = response.GetResponseStream())
                {
                    // Open the stream using a StreamReader for easy access.
                    StreamReader reader = new StreamReader(dataStream);
                    // Read the content.
                    string responseFromServer = reader.ReadToEnd();
                    // Display the content.
                    Console.WriteLine(responseFromServer);
                }

                // Close the response.
                response.Close();

                UpdateTariffe();
                

            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        protected void UpdateGraph()
        {
            try
            {
                string myURL = API_URL + "transazioni/settimanaScorsa";
                //string reqCity = txbCitta.Text;
                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);
                string responseFromServer = reader.ReadToEnd();

                List<GiornoDelGrafico> settimanaScorsa = new List<GiornoDelGrafico>();

                settimanaScorsa = JsonConvert.DeserializeObject<List<GiornoDelGrafico>>(responseFromServer);

                for (int i = 0; i < settimanaScorsa.Count; i++)
                {
                    arrSettimanaPrecedente[settimanaScorsa[i].giorno - 1] = settimanaScorsa[i].n_transazioni;
                }

            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati del grafico (settimana scorsa): " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }


            try
            {
                string myURL = API_URL + "transazioni/settimanaCorrente";
                //string reqCity = txbCitta.Text;
                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();

                List<GiornoDelGrafico> settimanaAttuale = new List<GiornoDelGrafico>();

                settimanaAttuale = JsonConvert.DeserializeObject<List<GiornoDelGrafico>>(responseFromServer);

                for (int i = 0; i < settimanaAttuale.Count; i++)
                {
                    arrSettimanaAttuale[settimanaAttuale[i].giorno - 1] = settimanaAttuale[i].n_transazioni;
                    
                    affluenzaSettimanale += settimanaAttuale[i].n_transazioni;
                }

                lblAffluenzaSettimanale.Text = affluenzaSettimanale.ToString();

            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati del grafico (settimana corrente): " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        protected void btnOrdinario_Click(object sender, EventArgs e)
        {
            btnAltaRotazione.Attributes["class"] = "btn btn-light w-100";
            btnOrdinario.Attributes["class"] = "btn btn-success w-100";
            btnTariffaForzata.Attributes["class"] = "btn btn-light w-100";

            UpdateModalitaTariffa(0);
            UpdateAffluenza();
            UpdateTariffe();
            divTariffaFissa.Visible = false;
            //txbTariffa.Attributes.Add("", "disabled"); ;
            //btnAggiorna.Attributes.Add("", "disabled"); ;
            //txbTariffa.Enabled = false;
            //btnAggiornaTariffa.Enabled = false;

        }

        protected void btnAltaRotazione_Click(object sender, EventArgs e)
        {
            btnOrdinario.Attributes["class"] = "btn btn-light w-100";
            btnAltaRotazione.Attributes["class"] = "btn btn-success w-100";
            btnTariffaForzata.Attributes["class"] = "btn btn-light w-100";

            UpdateModalitaTariffa(1);
            UpdateAffluenza();
            UpdateTariffe();
            divTariffaFissa.Visible = false;
            //txbTariffa.Enabled = false;
            //btnAggiornaTariffa.Enabled = false;
        }

        protected void btnTariffaForzata_Click(object sender, EventArgs e)
        {
            btnOrdinario.Attributes["class"] = "btn btn-light w-100";
            btnAltaRotazione.Attributes["class"] = "btn btn-light w-100";
            btnTariffaForzata.Attributes["class"] = "btn btn-success w-100";

            //data-toggle="tooltip" data-placement="top" title="Tooltip on top"
            txbTariffa.Attributes["data-toggle"] = "tooltip";
            txbTariffa.Attributes["data-placement"] = "top";
            txbTariffa.Attributes["title"] = "Inserisci la tariffa fissa!";
            
            divTariffaFissa.Visible = true;

            txbTariffa.Focus();


            UpdateModalitaTariffa(2);
            //txbTariffa.Enabled = true;
            //btnAggiornaTariffa.Enabled = true;

        }

        protected void UpdateModalitaTariffa(int n)
        {
            try
            {
                string myURL = API_URL + "modalitaTariffa/" + n;

 
                // Create a request using a URL that can receive a post.
                WebRequest request = WebRequest.Create(myURL);
                // Set the Method property of the request to POST.
                request.Method = "PUT";

                // Create POST data and convert it to a byte array.
                //string postData = "{ \"costo_forzato\": " + txbTariffa.Text + "}";

                byte[] byteArray = Encoding.UTF8.GetBytes("");

                // Set the ContentType property of the WebRequest.
                request.ContentType = "application/json";
                // Set the ContentLength property of the WebRequest.
                request.ContentLength = byteArray.Length;

                // Get the request stream.
                Stream dataStream = request.GetRequestStream();
                // Write the data to the request stream.
                dataStream.Write(byteArray, 0, byteArray.Length);
                // Close the Stream object.
                dataStream.Close();

                // Get the response.
                WebResponse response = request.GetResponse();
                // Display the status.
                Console.WriteLine(((HttpWebResponse)response).StatusDescription);

                // Get the stream containing content returned by the server.
                // The using block ensures the stream is automatically closed.
                using (dataStream = response.GetResponseStream())
                {
                    // Open the stream using a StreamReader for easy access.
                    StreamReader reader = new StreamReader(dataStream);
                    // Read the content.
                    string responseFromServer = reader.ReadToEnd();
                    // Display the content.
                    Console.WriteLine(responseFromServer);
                }

                // Close the response.
                response.Close();


            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        /*
        protected void Date1Change(object sender, EventArgs e)
        {
            
        }
        */

        /*
        protected void Date2Change(object sender, EventArgs e)
        {
            string myURL = "";
            try
            {
                //string myURL = API_URL_FILTRI + "&data_uscita_fine=" + Convert.ToDateTime(txbDataA.Text).ToString("yyyy'-'MM'-'dd");
                if (API_URL_FILTRI[API_URL_FILTRI.Length - 1] == '?') // se l'ultimo carattere è & vuol dire che ho già un parametro
                {
                    myURL = API_URL_FILTRI + "data_uscita_fine=" + Convert.ToDateTime(txbDataA.Text).ToString("yyyy'-'MM'-'dd");
 
                }
                else
                {
                    myURL = API_URL_FILTRI + "&data_uscita_fine=" + Convert.ToDateTime(txbDataA.Text).ToString("yyyy'-'MM'-'dd");

                }
                //string reqCity = txbCitta.Text;
                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();

                transazioni = JsonConvert.DeserializeObject<List<Transazioni>>(responseFromServer);
                grdTransazioni.DataSource = ConvertiListaTransazioniInDataTable(transazioni);
                grdTransazioni.DataBind();

                reader.Close();
                dataStream.Close();
                response.Close();




            }
            catch (InvalidCastException ex)
            {
                this.lblConsole.Text = "Errore nella traduzione dei dati del grafico (settimana corrente): " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }
            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;

                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        */

        protected void btnInviaMail_Click(object sender, EventArgs e)
        {
            string to = "pietro.beschin@stud.tecnicosuperiorekennedy.it"; //To address    
            string from = "andrea.gironda@stud.tecnicosuperiorekennedy.it"; //From address    
            MailMessage message = new MailMessage(from, to);

            string mailbody = txbMessaggio.InnerText;
            message.Subject = txbOggetto.Text;

            message.Body = mailbody;
            message.BodyEncoding = Encoding.UTF8;
            message.IsBodyHtml = true;
            SmtpClient client = new SmtpClient("smtp.gmail.com", 587); //Gmail smtp    

            System.Net.NetworkCredential basicCredential1 = new
            System.Net.NetworkCredential(from, "gironda01");
            client.EnableSsl = true;
            client.UseDefaultCredentials = false;
            client.Credentials = basicCredential1;
            try
            {
                client.Send(message);
                this.lblConsole.Text = "Mail inviata con successo: un nostro tecnico analizzerà la vostra richiesta il prima possibile!";
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-success";
                alertImg.Attributes["aria-label"] = "Success";
                alertImg.Attributes["href"] = "#check-circle-fill";
                txbOggetto.Text = "";
                txbMessaggio.InnerText = "";

            }

            catch (Exception ex)
            {
                this.lblConsole.Text = "Errore nell'invio della mail: " + ex.Message;
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";
            }
        }

        protected void btnFiltra_Click(object sender, EventArgs e)
        {
            string myURL = "";
            bool dataDaPresente = false;
            bool dataAPresente = false;
            try
            {
                if (txbDataDa.Text != "")
                {
                    dataDaPresente = true;
                }
                if (txbDataA.Text != "")
                {
                    dataAPresente = true;
                }

                if (txbDataDa.Text != "") // se c'è qualcosa
                {
                    myURL = API_URL_FILTRI + "data_uscita_inizio=" + Convert.ToDateTime(txbDataDa.Text).ToString("yyyy'-'MM'-'dd");
                }

                if (txbDataA.Text != "")
                {
                    if (dataDaPresente)
                    {
                        myURL = myURL + "&data_uscita_fine=" + Convert.ToDateTime(txbDataA.Text).ToString("yyyy'-'MM'-'dd");

                    } else
                    {
                        myURL = API_URL_FILTRI + "data_uscita_fine=" + Convert.ToDateTime(txbDataA.Text).ToString("yyyy'-'MM'-'dd");

                    }
                }
                /*
                this.lblConsole.Text = myURL ;

                alertObj.Attributes.Remove("hidden");*/
                //string reqCity = txbCitta.Text;
                //string myURL = baseURL + "weather?lang=it&units=metric&q=" + reqCity + "&appid=" + APIKEY;
                // CREO OGGETTO REQUEST
                WebRequest request = WebRequest.Create(myURL);
                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); // da errore se metti citta errata
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);

                string responseFromServer = reader.ReadToEnd();

                transazioni = JsonConvert.DeserializeObject<List<Transazioni>>(responseFromServer);
                grdTransazioni.DataSource = ConvertiListaTransazioniInDataTable(transazioni);
                grdTransazioni.DataBind();

                reader.Close();
                dataStream.Close();
                response.Close();




            }
            catch (InvalidCastException ex)
            {
                /*
                this.lblConsole.Text = "Errore nella traduzione dei dati del grafico (settimana corrente): " + ex.Message;

                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";*/
            }
            catch (Exception ex)
            {/*
                this.lblConsole.Text = "Errore nella connessione al database: " + ex.Message;

                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
                //this.alertObj.Attributes["class"] = "alert alert-danger";*/
            }
        }
    }


}