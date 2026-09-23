"""Geografia — Distribuzione del sistema universitario per area."""

import plotly.graph_objects as go
import streamlit as st

from sources import fmt_num, fmt_pct, load_mart, YEARS

st.title("Geografia")
st.caption("Dove si concentra l'università italiana")

year = st.selectbox("Anno", YEARS, index=len(YEARS) - 1)

df_all = load_mart("mur_iscritti", "mart_iscritti_concentrazione", 2025)
df = df_all[df_all["anno"] == year]

if df.empty:
    st.warning("Dati non disponibili.")
    st.stop()

# Distribuzione macro-area
st.subheader("Iscritti per macro-area")
df_area = df.groupby("macro_area", as_index=False).agg(totale=("totale", "sum"), n_atenei=("ateneo_cod", "nunique")).sort_values("totale", ascending=False)

fig = go.Figure(go.Bar(x=df_area["macro_area"], y=df_area["totale"], marker_color=["#6366f1", "#3b82f6", "#22c55e", "#f59e0b", "#ef4444"], text=df_area["totale"].apply(lambda x: fmt_num(int(x))), textposition="outside"))
fig.update_layout(height=350, yaxis_title="Iscritti", margin={"t": 20, "b": 40}, showlegend=False)
st.plotly_chart(fig, width="stretch")

st.divider()

# Concentrazione
st.subheader("Concentrazione")
k1, k2, k3 = st.columns(3)
top5 = df.nlargest(5, "totale")
top10 = df.nlargest(10, "totale")
k1.metric("Atenei totali", fmt_num(df["ateneo_cod"].nunique()))
k2.metric("Top 5 = % iscritti", f"{top5['totale'].sum() / df['totale'].sum() * 100:.1f}%")
k3.metric("Top 10 = % iscritti", f"{top10['totale'].sum() / df['totale'].sum() * 100:.1f}%")

# Atenei per area
st.subheader("Atenei per area geografica")
df_by_area = df.groupby(["macro_area", "ateneo_nome"], as_index=False).agg(totale=("totale", "sum"))
for area in sorted(df_by_area["macro_area"].unique()):
    n = df_area[df_area["macro_area"] == area]["n_atenei"].values[0]
    with st.expander(f"{area} ({n} atenei)"):
        df_sel = df_by_area[df_by_area["macro_area"] == area].sort_values("totale", ascending=False)
        fig = go.Figure(go.Bar(x=df_sel["totale"], y=df_sel["ateneo_nome"], orientation="h", marker_color="#6366f1", text=df_sel["totale"].apply(lambda x: fmt_num(int(x))), textposition="outside"))
        fig.update_layout(height=max(250, len(df_sel) * 25), xaxis_title="Iscritti", yaxis=dict(categoryorder="array", categoryarray=df_sel["ateneo_nome"].tolist()[::-1]), margin={"l": 200, "r": 20, "t": 10, "b": 40}, showlegend=False)
        st.plotly_chart(fig, width="stretch")
