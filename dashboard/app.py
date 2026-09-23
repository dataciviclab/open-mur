"""Università Intelligence — Dati aperti sul sistema universitario italiano."""

import streamlit as st
from lab_connectors.branding import apply_branding

st.set_page_config(page_title="Università Intelligence", page_icon="🎓", layout="wide")

apply_branding(repo_name="open-mur", repo_url="https://github.com/dataciviclab/open-mur")

pages = {
    "": [
        st.Page("pages/01_Panoramica.py", title="Panoramica", icon="📊", default=True),
    ],
    "Analisi": [
        st.Page("pages/02_Atenei.py", title="Atenei", icon="🏫"),
        st.Page("pages/03_Genere.py", title="Genere & STEM", icon="⚖️"),
        st.Page("pages/04_Geografia.py", title="Geografia", icon="🗺️"),
        st.Page("pages/05_Personale.py", title="Personale", icon="👩‍🏫"),
        st.Page("pages/06_Finanza.py", title="Finanza", icon="💰"),
    ],
    "Esplora": [
        st.Page("pages/07_Query_SQL.py", title="Query SQL", icon="🧪"),
    ],
}

pg = st.navigation(pages, position="sidebar")
pg.run()
