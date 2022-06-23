using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DashboardPW2022
{
    public class Transazioni
    {
        public string ID_rfid { get; set; }
        public DateTime data_entrata { get; set; }
        public DateTime data_uscita { get; set; }
        public double? importo { get; set; }
        public bool pagato { get; set; }
    }
}