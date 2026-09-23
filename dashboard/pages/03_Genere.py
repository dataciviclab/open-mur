"""Genere & STEM — Gap di genere per disciplina."""

import plotly.graph_objects as go
import streamlit as st

from sources import fmt_num, fmt_pct, load_mart, YEARS

st.title("Genere & STEM")
st.caption("Dove le donne sono sottorappresentate nelle discipline italiane")

year = st.selectbox("Anno", YEARS, index=len(YEARS) - 1)

df_imm_all = load_mart("mur_immatricolati", "mart_immatricolati_area", 2025)
df_imm = df_imm_all[df_imm_all["anno"] == year]

df_stem = load_mart("mur_crosswalk_stem", "mart_crosswalk_stem", 2025)

df = df_imm.merge(df_stem[["classe", "area_stem"]], left_on="classe_cod", right_on="classe", how="left")
df["area_stem"] = df["area_stem"].fillna("Non classificato")
df["area_stem"] = df["area_stem"].map({"S": "STEM", "No": "Non STEM"}).fillna("Non classificato")
df = df[df["totale"] > 50]

if df.empty:
    st.warning("Nessun dato disponibile.")
    st.stop()

# KPI
k1, k2, k3 = st.columns(3)
totale = df["totale"].sum()
donne = df["donne"].sum()
pct_donne_naz = 100.0 * donne / totale if totale > 0 else 0

k1.metric("Immatricolati", fmt_num(int(totale)))
k2.metric("% Donne nazionale", fmt_pct(pct_donne_naz, signed=False))
k3.metric("Classi STEM / non-STEM", f"{df[df['area_stem'] == 'STEM']['classe_cod'].nunique()} / {df[df['area_stem'] == 'Non STEM']['classe_cod'].nunique()}")

st.divider()

# % donne per area
st.subheader("% Donne per classe di laurea")
df_area = df.groupby("area_stem", as_index=False).agg(totale=("totale", "sum"), donne=("donne", "sum"))
df_area["pct_donne"] = 100.0 * df_area["donne"] / df_area["totale"]
df_area = df_area.sort_values("pct_donne", ascending=True)

fig = go.Figure(go.Bar(x=df_area["pct_donne"], y=df_area["area_stem"], orientation="h", marker_color=df_area["pct_donne"].apply(lambda x: "#ec4899" if x > 55 else "#6366f1" if x > 45 else "#3b82f6"), text=df_area["pct_donne"].apply(lambda x: f"{x:.1f}%"), textposition="outside"))
fig.add_vline(x=50, line_dash="dash", line_color="gray", annotation_text="Parità (50%)")
fig.update_layout(height=350, xaxis_title="% Donne", xaxis=dict(range=[0, 75]), margin={"l": 150, "r": 20, "t": 10, "b": 40}, showlegend=False)
st.plotly_chart(fig, width="stretch")

st.divider()

# Top/bottom
col1, col2 = st.columns(2)
with col1:
    st.subheader("Più femminili")
    st.dataframe(df.nlargest(10, "pct_donne")[["classe_nome", "totale", "pct_donne", "area_stem"]].rename(columns={"classe_nome": "Classe", "totale": "Iscritti", "pct_donne": "% Donne", "area_stem": "STEM"}), hide_index=True, width="stretch")
with col2:
    st.subheader("Più maschili")
    st.dataframe(df.nsmallest(10, "pct_donne")[["classe_nome", "totale", "pct_donne", "area_stem"]].rename(columns={"classe_nome": "Classe", "totale": "Iscritti", "pct_donne": "% Donne", "area_stem": "STEM"}), hide_index=True, width="stretch")
