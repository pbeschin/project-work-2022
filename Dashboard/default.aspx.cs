using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DashboardPW2022
{
    

    public partial class _default : System.Web.UI.Page
    {
        string USER = "test";
        string PASS = "Vmware1!";

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (this.txbUser.Text == USER && this.txbPass.Text == PASS)
            {
                Response.Redirect("~/dashboard.aspx");

            }
            else
            {
                this.lblConsole.Text = "Username o password errata";
                alertObj.Attributes.Remove("hidden");
                alertObj.Attributes["class"] = "alert alert-danger";
                alertImg.Attributes["aria-label"] = "Danger";
                alertImg.Attributes["href"] = "#exclamation-triangle-fill";
            }


        }

    }
}